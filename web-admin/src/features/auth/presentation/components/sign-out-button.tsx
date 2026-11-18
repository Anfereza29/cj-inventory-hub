'use client';

import { useTransition } from 'react';
import { useRouter } from 'next/navigation';
import { signOutAction } from '../actions/auth-actions';
import { authStrings } from '../strings/auth-strings';

/**
 * Logout control. Calls the signOut server action and redirects to /login (AC6).
 *
 * Uses useTransition so the pending flag is bound to the transition itself and
 * is cleared automatically when it finishes. This avoids a stale `loading`
 * state leaving the button disabled when the component is reused across
 * Next.js soft navigation.
 */
export function SignOutButton() {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();

  function handleClick() {
    startTransition(async () => {
      await signOutAction();
      router.replace('/login');
      router.refresh();
    });
  }

  return (
    <button
      type="button"
      onClick={handleClick}
      disabled={isPending}
      className="rounded-md border border-white/25 px-3 py-1.5 text-sm font-medium text-slate-100 transition hover:bg-white/10 hover:text-white disabled:opacity-60"
    >
      {authStrings.signOutButton}
    </button>
  );
}
