import { connection } from 'next/server';
import { EntryForm } from '@/features/inventory/presentation/components/entry-form';
import { inventoryStrings } from '@/features/inventory/presentation/strings/inventory-strings';

// Opt out of static-shell validation to stay consistent with the other
// admin pages; render at request time.
export const instant = false;

/** HU-01: register material entries against a purchase order. */
export default async function EntriesPage() {
  await connection();
  return (
    <section className="flex max-w-3xl flex-col gap-6">
      <h1 className="text-2xl font-semibold text-slate-900">{inventoryStrings.entriesTitle}</h1>
      <EntryForm />
    </section>
  );
}
