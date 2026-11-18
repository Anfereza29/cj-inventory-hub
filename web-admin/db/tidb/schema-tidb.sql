-- =====================================================================
-- Esquema completo para TiDB Cloud (Serverless).
-- Diferencias vs. MySQL local:
--   * Sin CREATE DATABASE / USE: en TiDB Cloud la base ya existe; se
--     selecciona en la cadena de conexión.
--   * Sin "ENGINE = InnoDB": TiDB lo ignora.
-- Compatible con FOREIGN KEY, CHECK, ENUM y UUID() (TiDB 7.x+).
-- Ejecutar este archivo completo en el SQL Editor de TiDB Cloud (o por CLI).
-- =====================================================================

-- ---------- Autenticación (equivale a 0001_init.sql) ----------
CREATE TABLE IF NOT EXISTS users (
  id            CHAR(36)     NOT NULL DEFAULT (UUID()),
  email         VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  full_name     VARCHAR(255) NOT NULL,
  role          ENUM('manager', 'site_engineer', 'accountant', 'warehouseman') NOT NULL,
  is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email)
);

-- ---------- Inventario (equivale a 0002_inventory.sql) ----------
CREATE TABLE IF NOT EXISTS materials (
  id            CHAR(36)     NOT NULL DEFAULT (UUID()),
  code          VARCHAR(40)  NOT NULL,
  description   VARCHAR(255) NOT NULL,
  unit          VARCHAR(20)  NOT NULL,
  abc_class     ENUM('A','B','C') NOT NULL DEFAULT 'C',
  reorder_point DECIMAL(12,2) NOT NULL DEFAULT 0,
  safety_stock  DECIMAL(12,2) NOT NULL DEFAULT 0,
  is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_materials_code (code)
);

CREATE TABLE IF NOT EXISTS projects (
  id         CHAR(36)     NOT NULL DEFAULT (UUID()),
  name       VARCHAR(255) NOT NULL,
  is_active  BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_projects_name (name)
);

CREATE TABLE IF NOT EXISTS work_fronts (
  id         CHAR(36)     NOT NULL DEFAULT (UUID()),
  project_id CHAR(36)     NOT NULL,
  name       VARCHAR(255) NOT NULL,
  is_active  BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_work_fronts_project (project_id),
  CONSTRAINT fk_work_fronts_project FOREIGN KEY (project_id) REFERENCES projects (id)
);

CREATE TABLE IF NOT EXISTS purchase_orders (
  id          CHAR(36)     NOT NULL DEFAULT (UUID()),
  oc_number   VARCHAR(40)  NOT NULL,
  supplier    VARCHAR(255) NOT NULL,
  project_id  CHAR(36)     NULL,
  status      ENUM('open','received','cancelled') NOT NULL DEFAULT 'open',
  created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_po_number (oc_number),
  CONSTRAINT fk_po_project FOREIGN KEY (project_id) REFERENCES projects (id)
);

CREATE TABLE IF NOT EXISTS purchase_order_items (
  id                CHAR(36)      NOT NULL DEFAULT (UUID()),
  purchase_order_id CHAR(36)      NOT NULL,
  material_id       CHAR(36)      NOT NULL,
  expected_qty      DECIMAL(12,2) NOT NULL,
  unit_price        DECIMAL(12,2) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_poi_po (purchase_order_id),
  KEY idx_poi_material (material_id),
  CONSTRAINT fk_poi_po FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders (id),
  CONSTRAINT fk_poi_material FOREIGN KEY (material_id) REFERENCES materials (id)
);

CREATE TABLE IF NOT EXISTS stock_movements (
  id                CHAR(36)      NOT NULL DEFAULT (UUID()),
  material_id       CHAR(36)      NOT NULL,
  movement_type     ENUM('in','out','adjust') NOT NULL,
  quantity          DECIMAL(12,2) NOT NULL,
  unit_cost         DECIMAL(12,2) NOT NULL DEFAULT 0,
  purchase_order_id CHAR(36)      NULL,
  work_front_id     CHAR(36)      NULL,
  operator_name     VARCHAR(255)  NULL,
  signature_data    MEDIUMTEXT    NULL,
  remission_note    VARCHAR(500)  NULL,
  created_by        CHAR(36)      NULL,
  created_at        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_sm_material (material_id),
  KEY idx_sm_type (movement_type),
  KEY idx_sm_front (work_front_id),
  CONSTRAINT chk_sm_qty CHECK (quantity > 0),
  CONSTRAINT fk_sm_material FOREIGN KEY (material_id) REFERENCES materials (id),
  CONSTRAINT fk_sm_po FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders (id),
  CONSTRAINT fk_sm_front FOREIGN KEY (work_front_id) REFERENCES work_fronts (id),
  CONSTRAINT fk_sm_user FOREIGN KEY (created_by) REFERENCES users (id)
);

CREATE TABLE IF NOT EXISTS planned_consumption (
  id            CHAR(36)      NOT NULL DEFAULT (UUID()),
  work_front_id CHAR(36)      NOT NULL,
  material_id   CHAR(36)      NOT NULL,
  planned_qty   DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_plan_front_material (work_front_id, material_id),
  CONSTRAINT fk_plan_front FOREIGN KEY (work_front_id) REFERENCES work_fronts (id),
  CONSTRAINT fk_plan_material FOREIGN KEY (material_id) REFERENCES materials (id)
);

CREATE OR REPLACE VIEW material_balances AS
SELECT
  m.id   AS material_id,
  m.code AS code,
  m.description AS description,
  m.unit AS unit,
  m.abc_class AS abc_class,
  m.reorder_point AS reorder_point,
  m.safety_stock AS safety_stock,
  COALESCE(SUM(CASE WHEN sm.movement_type = 'in' THEN sm.quantity
                    WHEN sm.movement_type = 'adjust' THEN sm.quantity
                    WHEN sm.movement_type = 'out' THEN -sm.quantity
                    ELSE 0 END), 0) AS balance
FROM materials m
LEFT JOIN stock_movements sm ON sm.material_id = m.id
WHERE m.is_active = TRUE
GROUP BY m.id, m.code, m.description, m.unit, m.abc_class, m.reorder_point, m.safety_stock;
