// filepath: src/shared/cart/types.ts
import type { Id } from '@/shared/types/common';

/**
 * CartEntry
 * - DB 테이블 TB_CART 기반 자동생성
 * - PK: CART_ID
 */
export type CartEntry = {
    id?: Id | null;
    userId?: number | null;
    statusCd?: string | null;
    useAt?: string | null;
    createdDt?: string | null;
    createdBy?: number | null;
    updatedDt?: string | null;
    updatedBy?: number | null;
};

/**
 * CartUpsertInput
 * - 업서트 API 파라미터 표준
 */
export type CartUpsertInput = {
    diaryDt: string;
    content: string;
    grpCd?: string | null;
    ownerId?: Id | null;
};
