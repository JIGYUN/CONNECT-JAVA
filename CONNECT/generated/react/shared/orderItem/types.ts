// filepath: src/shared/orderItem/types.ts
import type { Id } from '@/shared/types/common';

/**
 * OrderItemEntry
 * - DB 테이블 TB_ORDER_ITEM 기반 자동생성
 * - PK: ORDER_ITEM_ID
 */
export type OrderItemEntry = {
    id?: Id | null;
    orderId?: number | null;
    productId?: number | null;
    productNm?: string | null;
    qty?: number | null;
    unitPrice?: string | null;
    discountAmt?: string | null;
    lineAmt?: string | null;
    statusCd?: string | null;
    optionJson?: string | null;
    useAt?: string | null;
    createdDt?: string | null;
    createdBy?: number | null;
    updatedDt?: string | null;
    updatedBy?: number | null;
};

/**
 * OrderItemUpsertInput
 * - 업서트 API 파라미터 표준
 */
export type OrderItemUpsertInput = {
    diaryDt: string;
    content: string;
    grpCd?: string | null;
    ownerId?: Id | null;
};
