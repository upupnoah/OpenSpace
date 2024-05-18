with
    t as (
        SELECT
            "from",
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
    to holder,
    count(1) nft_cnt
from
    t
where
    rn = 1
group by
    to
order by
    count(1) desc