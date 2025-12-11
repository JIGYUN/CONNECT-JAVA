// filepath: src/shared/couponUser/types.ts
import type { Id } from '@/shared/types/common';

/**
 * CouponUserEntry
 * - DB 테이블 TB_COUPON_USER 기반 자동생성
 * - PK: COUPON_USER_ID
 */
export type CouponUserEntry = {
    id?: Id | null;
    couponId?: number | null;
    userId?: number | null;
    issueDt?: string | null;
    useDt?: string | null;
    statusCd?: string | null;
    orderId?: number | null;
    useAt?: string | null;
    createdDt?: string | null;
    createdBy?: number | null;
    updatedDt?: string | null;
    updatedBy?: number | null;
};

/**
 * CouponUserUpsertInput
 * - 업서트 API 파라미터 표준
 */
export type CouponUserUpsertInput = {
    diaryDt: string;
    content: string;
    grpCd?: string | null;
    ownerId?: Id | null;
};
