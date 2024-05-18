with
    t as (
        SELECT
            to,
            row_number() over (
                partition by
                    tokenId
                order by
                    evt_block_number desc,
                    evt_index desc
            ) rn
        FROM
            koda_lotm_v1_ethereum.Koda_evt_Transfer
        where
            contract_address = 0xe012baf811cf9c05c408e879c399960d1f305903
    )
select
    count(distinct to) holder_count
from
    t
where
    rn = 1