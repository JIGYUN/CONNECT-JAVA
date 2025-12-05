// filepath: src/shared/cartItem/types.ts
import type { Id } from '@/shared/types/common';

/**
 * CartItemEntry
 * - DB 테이블 TB_CART_ITEM 기반 자동생성
 * - PK: CART_ITEM_ID
 */
export type CartItemEntry = {
    id?: Id | null;
    cartId?: number | null;
    productId?: number | null;
    qty?: number | null;
    unitPrice?: string | null;
    discountAmt?: string | null;
    lineAmt?: string | null;
    optionJson?: string | null;
    useAt?: string | null;
    createdDt?: string | null;
    createdBy?: number | null;
    updatedDt?: string | null;
    updatedBy?: number | null;
};

/**
 * CartItemUpsertInput
 * - 업서트 API 파라미터 표준
 */
export type CartItemUpsertInput = {
    diaryDt: string;
    content: string;
    grpCd?: string | null;
    ownerId?: Id | null;
};
