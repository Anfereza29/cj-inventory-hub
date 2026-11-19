import { connection } from 'next/server';
import { QuickReceiptForm } from '@/features/inventory/presentation/components/quick-receipt-form';
import { inventoryStrings } from '@/features/inventory/presentation/strings/inventory-strings';

// The form loads live catalog data client-side; render at request time.
export const instant = false;

/**
 * Warehouseman landing: a simplified, mobile-first material reception screen.
 * Only the essentials (material + quantity + optional note).
 */
export default async function RecepcionPage() {
  await connection();

  return (
    <section className="mx-auto flex w-full max-w-md flex-col gap-6">
      <div className="flex flex-col gap-1">
        <h1 className="text-2xl font-bold text-slate-900">{inventoryStrings.receiptTitle}</h1>
        <p className="text-sm text-slate-500">{inventoryStrings.receiptSubtitle}</p>
      </div>
      <QuickReceiptForm />
    </section>
  );
}
