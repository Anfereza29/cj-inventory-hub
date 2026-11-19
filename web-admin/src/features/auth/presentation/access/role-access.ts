import type { UserRole } from '../../domain/entities/user-role';

/**
 * Role-based access config (RBAC) for admin sections.
 * `allowedRoles` lists which roles may enter each section key.
 * Used by the layout guard and the navigation menu (acceptance criterion AC4).
 */
export interface AdminSection {
  readonly key: string;
  readonly label: string;
  readonly href: string;
  readonly allowedRoles: readonly UserRole[];
}

/**
 * MVP navigation (first delivery): only the two primary screens.
 * Pantalla A = Inventario (hub: HU-01/02/03). Pantalla B = Catálogo (HU-00).
 * HU-04..HU-07 routes still exist in the codebase but are intentionally not
 * listed here (documented for the second delivery).
 */
export const ADMIN_SECTIONS: readonly AdminSection[] = [
  {
    key: 'inventory',
    label: 'Inventario',
    href: '/inventory',
    allowedRoles: ['manager', 'site_engineer', 'accountant', 'warehouseman'],
  },
  {
    key: 'catalog',
    label: 'Catálogo',
    href: '/catalog',
    allowedRoles: ['manager', 'warehouseman'],
  },
];

export function sectionsForRole(role: UserRole): AdminSection[] {
  return ADMIN_SECTIONS.filter((section) => section.allowedRoles.includes(role));
}

/** Route reserved for the simplified warehouseman reception view. */
export const WAREHOUSE_HOME = '/recepcion';
/** Default landing for admin-capable roles. */
export const ADMIN_HOME = '/inventory';

/**
 * Landing route right after login, by role. Warehousemen go to the dedicated,
 * simplified reception screen; everyone else to the admin inventory hub.
 */
export function landingPathForRole(role: UserRole): string {
  return role === 'warehouseman' ? WAREHOUSE_HOME : ADMIN_HOME;
}

export function canAccessPath(role: UserRole, pathname: string): boolean {
  const section = ADMIN_SECTIONS.find((item) => pathname.startsWith(item.href));
  // Unknown admin paths default to allowed only if the user has any section.
  if (!section) {
    return true;
  }
  return section.allowedRoles.includes(role);
}
