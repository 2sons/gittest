SELECT c.CustCd             AS customer_id,
       c.CustType           AS customer_type_cd,
       c.CusStatus          AS customer_status_cd,
       CASE
           WHEN ISDATE(replace(c.birth, '-', '')) = 1 THEN CONVERT(DATE, rtrim(replace(c.birth, '-', '')))
           ELSE NULL
           END              AS birth_ymd,
       CASE
           WHEN c.sex = '0' OR c.sex = '1' THEN c.sex
           ELSE NULL
           END              AS gender,
       CASE
           WHEN c.OwnRegNo IS NOT NULL AND c.OwnRegNo != '' THEN '1'
           ELSE '0'
           END              AS is_corporation,
       c.ZipCode            AS zipcode,
       c.Address1           AS address_parcel,
       ''                   AS sido,
       ''                   AS sigun,
       ''                   AS gu,
       ''                   AS dong,
       c.Address2           AS address_detail,
       c.OK_SMS             AS is_sms_consent,
       c.OK_Mail            AS is_mail_consent,
       c.OK_Call            AS is_call_consent,
       c.LicenType          AS license_type_cd,
       c.LicenNo            AS license_issue_area,
       c.LicenissueDt       AS license_issue_ymd,
       c.LicenLimitDt       AS license_expiry_ymd,
       c.AptTestEndDt       AS license_expiry_exam_ymd,
       CASE
           WHEN c.JoinDt IS NOT NULL AND c.JoinDt != '' THEN '1'
           ELSE '0'
           END              AS is_regular,
       c.PostType           AS rfid_receipt_cd,
       c.PostStatus         AS rfid_receipt_status_cd,
       c.RFID_TYPE          AS rfid_type_cd,
       c.CusCountry         AS nationality,
       c.GreenMaster        AS is_admin,
       c.dupinfo            AS sns_login_cd,
       ci.Reg_Gubun         AS join_cd,
       c.FriendCustCd       AS recommender_id,
       CASE
           WHEN pay.pay_auth IS NOT NULL AND pay.pay_auth != '' THEN '1'
           ELSE '0'
           END              AS is_pay_registration,
       CASE
           WHEN MO.UUID IS NOT NULL AND MO.UUID != '' THEN '1'
           ELSE '0'
           END              AS is_mobile_certification,
       ci.Phone_YN          AS is_self_certification,
       ci.Ktmembership_Card AS ktmemebership_card_no,
       CASE
           WHEN ci.Ktmembership_Card IS NOT NULL AND ci.Ktmembership_Card != '' THEN '1'
           ELSE '0'
           END              AS is_kt,
       CASE
           WHEN (SELECT COUNT(ORDERID)
                 FROM CACAOCAR.DBO.RENTORDER AS F
                 WHERE c.CustCd = F.CustCd
                   AND OrderStatus IN (3, 4)) > 0 THEN '1'
           ELSE '0'
           END              AS is_first_rent,
       ci.CUST_IDENTITY     AS cust_claim_level,
       (SELECT DISTINCT last_value(AD_YN) OVER (ORDER BY cad.CustCd ) AS LAST_AD_YN
        FROM CACAOCAR.DBO.Customer_Ad_Push_Info AS cad
        WHERE cad.CustCd = c.CustCd
       )                    AS is_push_ad_consent,
       CASE
           WHEN ci.Campus_Owner_CustCd IS NOT NULL AND ci.Campus_Owner_CustCd != '' THEN '1'
           ELSE '0'
           END              AS is_campus,
       CASE
           WHEN am.OwnerCustCd IS NOT NULL AND am.OwnerCustCd != '' THEN '1'
           ELSE '0'
           END              AS is_village,
       (SELECT COUNT(r.OrderID)
        FROM CACAOCAR.dbo.RentOrder AS r
        WHERE c.CustCd = r.CustCd
          AND OrderStatus IN (3, 4)
       )                    AS total_rent_cnt,
       c.RegDt				AS associate_member_at,
	   c.JoinDt				AS regular_member_at
FROM CACAOCAR.dbo.Customer AS c WITH (NOLOCK)
LEFT JOIN CACAOCAR.dbo.ApartAgentMap AS am WITH (NOLOCK) ON c.CustCd = am.OwnerCustCd
LEFT JOIN CACAOCAR.dbo.Customer_Add_Info AS ci WITH (NOLOCK) ON c.CustCd = ci.CustCd
LEFT JOIN CACAOCAR.DBO.CUSTOMER_MO_INFO AS MO WITH (NOLOCK) ON c.CustCd = MO.CustCd
LEFT JOIN ( SELECT CustCd , MAX (pay_auth) AS pay_auth
            FROM CACAOCAR.DBO.Customer_CF_CARD WITH (NOLOCK)
            GROUP BY CustCd ) AS pay ON c.CustCd = pay.CustCd

