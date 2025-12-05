// filepath: src/shared/order/types.ts
import type { Id } from '@/shared/types/common';

/**
 * OrderEntry
 * - DB 테이블 TB_ORDER 기반 자동생성
 * - PK: ORDER_ID
 */
export type OrderEntry = {
    id?: Id | null;
    orderNo?: string | null;
    userId?: number | null;
    orderStatusCd?: string | null;
    payStatusCd?: string | null;
    payMethodCd?: string | null;
    totalProductAmt?: string | null;
    totalDiscountAmt?: string | null;
    deliveryAmt?: string | null;
    orderAmt?: string | null;
    pointUseAmt?: string | null;
    pointSaveAmt?: string | null;
    couponUseAmt?: string | null;
    payAmt?: string | null;
    receiverNm?: string | null;
    receiverPhone?: string | null;
    zipCode?: string | null;
    addr1?: string | null;
    addr2?: string | null;
    deliveryMemo?: string | null;
    useAt?: string | null;
    createdDt?: string | null;
    createdBy?: number | null;
    updatedDt?: string | null;
    updatedBy?: number | null;
};

/**
 * OrderUpsertInput
 * - 업서트 API 파라미터 표준
 */
export type OrderUpsertInput = {
    diaryDt: string;
    content: string;
    grpCd?: string | null;
    ownerId?: Id | null;
};
