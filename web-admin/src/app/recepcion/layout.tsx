import { redirect } from 'next/navigation';
import { provideServerAuthRepository } from '@/core/di/auth.di.server';
import { GetCurrentUser } from '@/features/auth/domain/usecases/get-current-user';
import { ADMIN_HOME } from '@/features/auth/presentation/access/role-access';
import { SignOutButton } from '@/features/auth/presentation/components/sign-out-button';

// Reads the session cookie on every request; blocking route.
export const instant = false;

/**
 * Dedicated layout for the simplified warehouseman reception view.
 * Guard:
 *  - No session        -> /login
 *  - Non-warehouseman  -> /inventory (admin roles use the full panel)
 * Header is intentionally minimal (brand + user + sign out), mobile-first.
 */
export default async function RecepcionLayout({ children }: LayoutProps<'/'>) {
  const result = await new GetCurrentUser(provideServerAuthRepository()).execute();

  if (!result.ok || !result.value) {
    redirect('/login');
  }

  const user = result.value;
  if (user.role !== 'warehouseman') {
    redirect(ADMIN_HOME);
  }

  return (
    <div className="flex min-h-screen flex-col">
      <header className="flex items-center justify-between bg-gradient-to-r from-brand-darker to-brand px-5 py-3 shadow-sm">
        <span className="font-semibold text-white">Constructora C&amp;J</span>
        <div className="flex items-center gap-3">
          <span className="hidden text-sm text-slate-300 sm:inline">{user.fullName}</span>
          <SignOutButton />
        </div>
      </header>
      <main className="flex-1 px-4 py-8">{children}</main>
    </div>
  );
}
