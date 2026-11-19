import { failure, type Result } from '@/core/result';
import type {
  InventoryRepository,
  QuickReceiptInput,
} from '../repositories/inventory-repository';

/**
 * Warehouseman flow: register a simplified material reception.
 * Records an incoming ('in') movement with just material + quantity (and an
 * optional note), with no purchase order involved. Pure domain: validates
 * input and delegates to the repository, which writes to the Kardex.
 */
export class RegisterQuickReceipt {
  constructor(private readonly repo: InventoryRepository) {}

  execute(input: QuickReceiptInput): Promise<Result<void>> {
    if (input.materialId.trim().length === 0) {
      return Promise.resolve(failure('INVALID_INPUT', 'Material is required.'));
    }
    if (!Number.isFinite(input.quantity) || input.quantity <= 0) {
      return Promise.resolve(failure('INVALID_INPUT', 'Quantity must be greater than 0.'));
    }
    return this.repo.registerQuickReceipt(input);
  }
}
