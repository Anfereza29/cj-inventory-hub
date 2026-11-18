import { redirect } from 'next/navigation';
import { provideServerAuthRepository } from '@/core/di/auth.di.server';
import { GetCurrentUser } from '@/features/auth/domain/usecases/get-current-user';
import { LoginContainer } from '@/features/auth/presentation/containers/login-container';

// Reads the session cookie (cookies()) on every request; blocking route.
export const instant = false;

/**
 * Thin login route. Delegates rendering to LoginContainer.
 * If a session already exists, go straight to the inventory hub.
 */
export default async function LoginPage() {
  const getCurrentUser = new GetCurrentUser(provideServerAuthRepository());
  const result = await getCurrentUser.execute();
  if (result.ok && result.value) {
    redirect('/inventory');
  }

  return (
    <main className="grid min-h-screen grid-cols-1 md:grid-cols-[minmax(0,420px)_1fr]">
      {/* Brand panel (hidden on small screens so the form takes the full width). */}
      <aside className="relative hidden flex-col justify-center overflow-hidden bg-gradient-to-br from-brand-darker to-brand px-12 py-16 md:flex">
        {/* Soft decorative circles */}
        <span className="pointer-events-none absolute -left-24 -top-16 h-64 w-64 rounded-full bg-white/5" />
        <span className="pointer-events-none absolute -bottom-24 right-0 h-72 w-72 rounded-full bg-white/5" />

        <div className="relative flex flex-col gap-2">
          <div className="flex h-14 w-14 items-center justify-center rounded-xl bg-brand text-lg font-extrabold text-accent-soft ring-1 ring-white/10">
            C&amp;J
          </div>
          <h1 className="mt-4 text-4xl font-extrabold tracking-tight text-white">ConstructJet</h1>
          <p className="text-sm text-slate-400">Sistema de inventario de obra</p>
        </div>

        <div className="relative mt-16">
          <div className="h-px w-32 bg-slate-600" />
          <p className="mt-4 text-sm font-semibold text-slate-200">Constructora C&amp;J</p>
          <p className="text-xs text-slate-400">Uso interno · acceso restringido</p>
        </div>
      </aside>

      {/* Form area */}
      <section className="flex items-center justify-center px-4 py-12">
        <LoginContainer />
      </section>
    </main>
  );
}
