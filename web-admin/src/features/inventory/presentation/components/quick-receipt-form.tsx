'use client';

import { useEffect, useState, useTransition } from 'react';
import {
  listMaterialsAction,
  registerQuickReceiptAction,
} from '../actions/inventory-actions';
import { inventoryStrings } from '../strings/inventory-strings';

interface MaterialOption {
  id: string;
  code: string;
  description: string;
  unit: string;
}

/**
 * Warehouseman reception form. Three fields max (material, quantity, optional
 * note), large touch targets, mobile-first. On success it shows a confirmation
 * so the operator can quickly register another reception.
 */
export function QuickReceiptForm() {
  const [materials, setMaterials] = useState<MaterialOption[]>([]);
  const [loadingMaterials, setLoadingMaterials] = useState(true);
  const [materialId, setMaterialId] = useState('');
  const [quantity, setQuantity] = useState('');
  const [note, setNote] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [done, setDone] = useState(false);
  const [isSaving, startSave] = useTransition();

  useEffect(() => {
    let active = true;
    listMaterialsAction().then((result) => {
      if (!active) return;
      if (result.ok && result.materials) {
        setMaterials(result.materials);
      } else {
        setError(result.error ?? inventoryStrings.genericError);
      }
      setLoadingMaterials(false);
    });
    return () => {
      active = false;
    };
  }, []);

  function resetForNext() {
    setDone(false);
    setMaterialId('');
    setQuantity('');
    setNote('');
    setError(null);
  }

  function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    const qty = Number(quantity);
    if (materialId.length === 0) {
      setError(inventoryStrings.required);
      return;
    }
    if (!Number.isFinite(qty) || qty <= 0) {
      setError(inventoryStrings.required);
      return;
    }
    startSave(async () => {
      const result = await registerQuickReceiptAction({
        materialId,
        quantity: qty,
        note: note.trim().length > 0 ? note.trim() : null,
      });
      if (result.ok) {
        setDone(true);
      } else {
        setError(result.error ?? inventoryStrings.genericError);
      }
    });
  }

  const fieldClass =
    'w-full rounded-lg border border-slate-300 px-4 py-3 text-base text-slate-900 outline-none focus:border-brand focus:ring-2 focus:ring-accent/30';
  const labelClass = 'flex flex-col gap-1.5 text-sm font-semibold text-slate-700';

  if (done) {
    return (
      <div className="flex flex-col items-center gap-6 rounded-2xl border border-slate-200 bg-white p-8 text-center shadow-sm">
        <div className="flex h-16 w-16 items-center justify-center rounded-full bg-green-100 text-3xl text-green-700">
          ✓
        </div>
        <p className="text-lg font-semibold text-slate-900">
          {inventoryStrings.receiptRegistered}
        </p>
        <button
          type="button"
          onClick={resetForNext}
          className="w-full rounded-lg bg-brand px-4 py-3 text-base font-semibold text-white transition hover:bg-brand-dark"
        >
          {inventoryStrings.receiptNewOne}
        </button>
      </div>
    );
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="flex flex-col gap-5 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm"
    >
      <label className={labelClass}>
        {inventoryStrings.receiptMaterialLabel}
        <select
          value={materialId}
          onChange={(e) => setMaterialId(e.target.value)}
          disabled={loadingMaterials}
          className={fieldClass}
          required
        >
          <option value="" disabled>
            {loadingMaterials ? inventoryStrings.saving : inventoryStrings.receiptMaterialPlaceholder}
          </option>
          {materials.map((m) => (
            <option key={m.id} value={m.id}>
              {m.code} · {m.description} ({m.unit})
            </option>
          ))}
        </select>
      </label>

      <label className={labelClass}>
        {inventoryStrings.receiptQuantityLabel}
        <input
          type="number"
          inputMode="decimal"
          min="0.01"
          step="0.01"
          value={quantity}
          onChange={(e) => setQuantity(e.target.value)}
          placeholder="0"
          className={fieldClass}
          required
        />
      </label>

      <label className={labelClass}>
        {inventoryStrings.receiptNoteLabel}
        <input
          type="text"
          value={note}
          onChange={(e) => setNote(e.target.value)}
          placeholder={inventoryStrings.receiptNotePlaceholder}
          maxLength={500}
          className={fieldClass}
        />
      </label>

      {!loadingMaterials && materials.length === 0 ? (
        <p className="text-sm text-amber-700">{inventoryStrings.receiptNoMaterials}</p>
      ) : null}

      {error ? (
        <p role="alert" className="text-sm text-red-600">
          {error}
        </p>
      ) : null}

      <button
        type="submit"
        disabled={isSaving || loadingMaterials}
        className="mt-1 rounded-lg bg-brand px-4 py-3.5 text-base font-semibold text-white transition hover:bg-brand-dark disabled:opacity-60"
      >
        {isSaving ? inventoryStrings.receiptSubmitting : inventoryStrings.receiptSubmit}
      </button>
    </form>
  );
}
