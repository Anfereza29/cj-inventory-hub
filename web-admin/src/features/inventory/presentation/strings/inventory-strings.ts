/** User-facing Spanish text for the inventory feature, centralized. */
export const inventoryStrings = {
  // Common
  save: 'Guardar',
  saving: 'Guardando...',
  genericError: 'Ocurrió un error. Inténtalo de nuevo.',
  required: 'Campo obligatorio.',

  // Kardex (HU-03)
  kardexTitle: 'Control de Inventario y Kardex en Tiempo Real',
  statusOk: 'Stock óptimo',
  statusReorder: 'Punto de pedido',
  statusCritical: 'Alerta roja (comprar)',
  formulaNote: 'Saldo = Saldo Inicial + Entradas − Salidas',

  // Catalog (HU-00)
  catalogTitle: 'Catálogo de materiales',
  newMaterial: 'Nuevo material',
  codeLabel: 'Código',
  descriptionLabel: 'Descripción',
  unitLabel: 'Unidad',
  abcLabel: 'Clasificación ABC',
  reorderLabel: 'Punto de pedido (PP)',
  safetyLabel: 'Stock de seguridad (SS)',
  materialCreated: 'Material creado.',

  // Entries (HU-01)
  entriesTitle: 'Registro de entrada de almacén',
  ocLabel: 'Número de orden de compra (OC)',
  searchOc: 'Buscar OC',
  supplierLabel: 'Proveedor',
  realQtyLabel: 'Cantidad real recibida',
  noveltyLabel: 'Novedad u observación',
  confirmEntry: 'Confirmar ingreso y cargar a Kardex',
  entryRegistered: 'Entrada registrada y Kardex actualizado.',
  ocNotFound: 'No se encontró la orden de compra.',

  // Issue voucher (HU-02)
  issueTitle: 'Vale de salida digital',
  workFrontLabel: 'Frente de obra / actividad',
  operatorLabel: 'Operario / contratista que recibe',
  materialLabel: 'Material',
  quantityLabel: 'Cantidad',
  signatureLabel: 'Firma digital de conformidad',
  clearSignature: 'Borrar firma',
  observationsLabel: 'Observaciones (opcional)',
  dispatch: 'Despachar y actualizar stock',
  issueRegistered: 'Vale registrado y stock descontado.',

  // Reconciliation (HU-04)
  countTitle: 'Conteo físico y conciliación',
  countedLabel: 'Cantidad contada',
  systemBalance: 'Saldo del sistema',
  difference: 'Diferencia',
  countRegistered: 'Conteo registrado.',

  // Deviation (HU-05)
  deviationTitle: 'Desviación de consumo por actividad',
  plannedQty: 'Planificado',
  realQty: 'Real',
  deviationPct: 'Desviación (%)',

  // Report (HU-06 / HU-07)
  reportTitle: 'Informe quincenal de costos por obra',
  projectLabel: 'Obra',
  fromLabel: 'Desde',
  toLabel: 'Hasta',
  generate: 'Generar informe',
  exportExcel: 'Exportar a Excel',
  consumedQty: 'Consumo',
  totalCost: 'Costo total',

  // Warehouseman reception view (vista dedicada del obrero)
  receiptTitle: 'Registrar entrada de material',
  receiptSubtitle: 'Selecciona el material y la cantidad recibida.',
  receiptMaterialLabel: 'Material',
  receiptMaterialPlaceholder: 'Elige un material…',
  receiptQuantityLabel: 'Cantidad recibida',
  receiptNoteLabel: 'N° de remisión o nota (opcional)',
  receiptNotePlaceholder: 'Ej: Remisión 1234 / proveedor',
  receiptSubmit: 'Registrar entrada',
  receiptSubmitting: 'Registrando…',
  receiptRegistered: 'Entrada registrada correctamente.',
  receiptNewOne: 'Registrar otra entrada',
  receiptNoMaterials: 'No hay materiales activos en el catálogo.',
  receiptSignOut: 'Salir',
} as const;
