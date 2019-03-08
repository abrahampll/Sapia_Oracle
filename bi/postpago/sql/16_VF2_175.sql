WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;
BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_vf2_175_masivo');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_vf2_175_corporativo');

END;
/
CREATE TABLE DM.DW_vf2_175_masivo NOLOGGING AS
SELECT TO_CHAR(S.ENTRY_DATE, 'YYYYMM') as PERIODO, PP.DN_NUM AS LINEA ,PP.customer_id,pp.co_id, COUNT(SH.SNCODE) AS SNCODE
FROM DMRED.PROFILE_SERVICE S, DMRED.PR_SERV_STATUS_HIST SH, DMRED.PP_DATOS_CONTRATO PP, DWS.SA_TIM_CONSOL_CLIENTE_REF CR, DMRED.MPUSNTAB DS
WHERE S.CO_ID = SH.CO_ID
AND S.SNCODE = SH.SNCODE
AND S.STATUS_HISTNO = SH.HISTNO
AND SH.STATUS = 'A'
AND SH.SNCODE IN  ('2171','2170','1915','2172',  '1911','1910','1912','2173','1913','2174','1909','1908','1914',  
'2385','2386','2319','2320','2318','2354','1513','1593','1590','1591','1592','2790','2787','2791','2788',
'2789','2966','2967','2163','2160','2161','2162','2964','2965','2962','2963','2891','2393','2353','2351', 
'2352','2397','2398','2396','2400','2401','2399','2394','2395','1522','1447','1441','1446','1452','1440',
'1660','2509','1594','1501','2510','2507','1646','1499','2619','1562','2508','1772','1502','2512','2620',
'1371','1365','1366','1372','1369','1370','1367','1405','2762','2763','2764','2760','2761','1463','1577',
'1580','1466','1476','1579','2521','2792','2522','2520','2524','1586','1583','1584','1587','1585','1642',
'1639','1640','1643','1641','1721','1724','1722','1723','1720','2514','1669','1716','2363','1717','2515',
'1336','1745','2707','2516','1718','1346','1337','1330','1322','1326','1328','1331','1323','1333','1324',
'1332','1327','1329','1325','1902','1905','1906','1903','1907','1904','1750','1650','1651','1456','1753',
'1490','2558','2555','2556','2557','1685','1686','1682','1683','1687','1684','1245','1670','1705','1554',
'3115','1511','2747','2955','3216','3215','2476','1908','1910','1909','1911','1912','1913','1914','1915',
'2787','2788','2789','2790','2791','2160','2161','2162','2964','2965','2962','2963','2966','2967','3215',
'3216','3757','3758','3759','3760','3761','3762','3763','3764','3765','3766','3767','3768','3769','3770','3771') 
and s.sncode=ds.sncode
and pp.co_id = s.co_id
and pp.ch_status = 'a'
and pp.customer_id=cr.customer_id 
and cr.prgcode=2
and to_char (s.entry_date, 'YYYYMM') = '&1'
GROUP BY TO_CHAR(S.ENTRY_DATE, 'YYYYMM') , PP.DN_NUM,PP.customer_id,pp.co_id  ;

CREATE TABLE DM.DW_vf2_175_corporativo NOLOGGING AS
SELECT TO_CHAR(S.ENTRY_DATE, 'YYYYMM') as PERIODO, PP.DN_NUM AS LINEA ,PP.customer_id,pp.co_id, COUNT(SH.SNCODE) AS SNCODE
FROM DMRED.PROFILE_SERVICE S, DMRED.PR_SERV_STATUS_HIST SH, DMRED.PP_DATOS_CONTRATO PP, DWS.SA_TIM_CONSOL_CLIENTE_REF CR, DMRED.MPUSNTAB DS
WHERE S.CO_ID = SH.CO_ID
AND S.SNCODE = SH.SNCODE
AND S.STATUS_HISTNO = SH.HISTNO
AND SH.STATUS = 'A'
AND SH.SNCODE IN ( '8','9','10','20','31','32','33','34','35','36','39','40','47','80','94','1123','95','96','98','99','100','101','121','122','123','124','125','126',
'127','128','144','145','161','164','165','166','1005','1007','1008','1010','1011','1012','1013','1014','1015','1016','1017','1018'
,'1047','1048','1049','1099','1100','1101','1102','1103','1115','1148','1175','1176','1182','1425','1244','1243','1245','1246'
,'1280','1296','1308','1313','1318','1319','1320','1348','1351','1353','1382','1400','1401','1402','1403','1433','1434','1437',
'1438','1439','1442','1443','1444','1445','1449','1450','1451','1454','1456','1457','1458','1459','1460','1461','1462','1463'
,'1464','1465','1466','1467','1533','1468','1469','1470','1471','1472','1473','1474','1475','1476','1477','1480','1481','1482'
,'1483','1484','1485','1490','1491','1498','1499','2299','1522','1524','1525','1526','1554','156','1625','1626','1571','1572'
,'1573','1574','1575','1576','1577','1578','1579','1580','1637','1638','1632','1629','1660','1711','1714','1758','1759','1760'
,'2224','2225','2226','2227','2285','2286','2288','2287','2289','2290','2291','2292','1735','2293','2294','2295','2296','2327','2328',
'2329','2330','2331','2332','2333','2334','2335','2336','2337','2343','2344','2377','2378','2379','2380','2474','1700','2503'
,'2504','2505','2506','64','1605','2526','2527','1','2540','2541','2542','2595','2700','2701','2702','2703','2704','2705'
,'2754','2747','2757','2758','2759','2765','2891','2971','2981','2986','2987','2988','3133','3142','3143','3144','3145'
,'3146','3147','3148','3297','3298','3486','3487','3488','3489','3642','3757','3758','3759','3760','3761','3762','3772'
,'3773','3774','3775','3776','3777','3778','3779','29','60','146','147','17','21','28','162','163','97','87','88','89','90','1352'
,'1406','1407','1408','1409','1410','1411','1412','1413','1414','1415','1416','1417','1418','1419','1420','1534','1550','1564'
,'81','1730','1731','1732','1733','1736','1842','1705','1741','1788','2161','2215','2216','2217','2218','2219','2220','2306'
,'2307','2339','2375','2376','2362','2746','2760','2761','2762','2763','2764','2905','2966','2967','1184','1670','1734','1837'
,'1839','2740','1644','118','1009','1125','1201','1250','2994','1910','1911','1909','1913','2962','2963','2964','2965','3764'
,'3765','3766','3767','3768','3769','3770','3771','1255','1256','2169','1707','1594','1715','2530','2531','2707','63','18','1502'
,'1702','1706','1151','1183','1269','1270','1448','1501','1503','1504','1505','1513','1655','1656','1645','1712','2221','2222'
,'2223','2283','2284','2297','2594','2662','2663','2664','2665','1559','2532','27','2384','2383','2476','2537','1751','23'
,'1539','1548','1772','1774','1747','2360','2472','2545','2792','3118','2167','2502','2528','1912','1914','1915','2170'
,'2171','2172','2173','2174','2385','2386','2543') 
and s.sncode=ds.sncode
and pp.co_id = s.co_id
and pp.ch_status = 'a'
and pp.customer_id=cr.customer_id 
and cr.prgcode in (1,5)
and to_char (s.entry_date, 'YYYYMM') = '&1'
GROUP BY TO_CHAR(S.ENTRY_DATE, 'YYYYMM') , PP.DN_NUM,PP.customer_id,pp.co_id  ;

INSERT INTO DWM.DW_vf2_175_masivo SELECT * FROM DM.DW_vf2_175_masivo; 
COMMIT;
INSERT INTO DWM.DW_vf2_175_corporativo SELECT * FROM DM.DW_vf2_175_corporativo; 
COMMIT;

DROP TABLE DM.DW_vf2_175_masivo PURGE;
DROP TABLE DM.DW_vf2_175_corporativo PURGE;

EXIT;