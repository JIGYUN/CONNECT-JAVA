// filepath: src/shared/coupon/types.ts
import type { Id } from '@/shared/types/common';

/**
 * CouponEntry
 * - DB 테이블 TB_COUPON 기반 자동생성
 * - PK: COUPON_ID
 */
export type CouponEntry = {
    id?: Id | null;
    couponCd?: string | null;
    couponNm?: string | null;
    couponTypeCd?: string | null;
    discountRate?: string | null;
    discountAmt?: string | null;
    maxDiscountAmt?: string | null;
    minOrderAmt?: string | null;
    maxIssueCnt?: number | null;
    perUserMaxCnt?: number | null;
    startDt?: string | null;
    endDt?: string | null;
    useAt?: string | null;
    memo?: string | null;
    createdDt?: string | null;
    createdBy?: number | null;
    updatedDt?: string | null;
    updatedBy?: number | null;
};

/**
 * CouponUpsertInput
 * - 업서트 API 파라미터 표준
 */
export type CouponUpsertInput = {
    diaryDt: string;
    content: string;
    grpCd?: string | null;
    ownerId?: Id | null;
};
