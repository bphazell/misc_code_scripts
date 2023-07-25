with cost as (
select (sum(c.amount) + (sum(c.amount) * (j.markup::numeric / 100))) as cost, c.job_id
from public.builder_conversions c
join public.builder_jobs j on j.id = c.job_id
Where c.worker_id in ('33653714'
'33081299',
'22465363',
'31668889',
'34929784',
'30764920',
'26737823',
'32356300',
'32616093',
'22886152',
'37539733',
'35275620',
'37881707',
'37729253',
'35481760',
'24590438',
'21303500',
'32609858',
'32355224',
'33064854',
'33687647',
'33927026',
'27722469',
'22500773',
'37539725',
'32354146',
'38089851',
'34325473',
'23049406',
'34631006',
'33968289',
'37883753',
'25777350',
'33653648',
'34318322',
'32616118',
'34392953',
'32357118',
'25480855',
'36130770',
'34392378',
'33362908',
'35113873',
'21305078',
'32351984',
'32365768',
'18231812',
'38019958',
'35689223',
'21680730',
'22097615',
'33434055',
'22468582',
'32033532',
'21213722',
'27722598',
'22428048',
'31914384',
'34325337',
'32814613',
'36131277',
'31832311',
'30070462',
'22884223',
'26758135',
'21743435',
'33064431',
'32616022',
'30071649',
'32352389',
'21674694',
'22222960',
'21396240',
'22050439',
'33678296',
'32357339',
'33301099',
'22885569',
'25662625',
'33675569',
'22500756',
'21703364',
'21213857',
'27722517',
'36130318',
'34630926',
'32593398',
'34630814',
'35256778',
'12530015',
'25606600',
'32365662',
'34343517',
'32616038',
'32609930',
'33081531',
'33426493',
'33301357',
'23343032',
'33081363',
'22044440',
'36130254',
'35477713',
'37876875',
'33064649',
'16880192',
'36129444',
'35284384',
'16881182',
'32616069',
'34630760',
'34392326',
'34392224',
'31668408',
'34068305',
'33523233',
'35322110',
'37737611',
'37539717',
'36129492',
'22526306',
'30070453',
'32693849',
'21504584',
'34635150',
'22044471',
'33511293',
'34318383',
'33300965',
'25480796',
'33926948',
'32587270',
'22247867',
'34392168',
'22247433',
'32365063',
'33272155',
'32081416',
'36131235',
'27886237',
'36279255',
'25777210',
'35102875',
'29472437',
'32365049',
'37884727',
'21400613',
'36130729',
'21224971',
'37709667',
'32615952',
'21283280',
'33927048',
'34550621',
'33926916',
'25480942',
'27722450',
'26758189',
'32365756',
'34233947',
'34330401',
'24198663',
'28384742',
'33568680',
'25464796',
'22045113',
'34630807',
'30071623',
'36279134',
'27722557',
'30229996',
'22082304',
'32357134',
'33668967',
'25193547',
'32463376',
'32082320',
'35488810',
'6333208',
'36215354',
'25470964',
'32365042',
'33927005',
'33568745',
'38067351',
'37539683',
'25169810',
'22247909',
'34325689',
'32365055',
'11031865',
'35681561',
'36279128',
'33678300',
'34252583',
'21504504',
'37881716',
'22247437',
'35682180',
'35636365',
'25169846',
'21209645',
'20598738',
'34630651',
'36279167',
'27033721',
'22297276',
'32365774',
'33064084',
'26546774',
'33066213',
'32609910',
'37539672',
'29545498',
'22465712',
'34112311',
'21213852',
'32357345',
'32356309',
'32365083',
'33433998',
'21384765',
'29458969',
'33066384',
'29466758',
'34392367',
'34631047',
'32404911',
'34630694',
'34392853',
'21213723',
'37778490',
'37851621',
'34318187',
'21682695',
'35284455',
'34930434',
'33301338',
'34941591',
'33568701',
'31668312',
'32082605',
'32070850',
'33065741',
'22895147',
'32356292',
'34121020',
'16858108',
'36085043',
'21400557',
'35004293',
'22044466',
'35282203',
'33425290',
'34330116',
'25467692',
'33063641',
'25482164',
'36279054',
'32082281',
'34325405',
'32356316',
'32032908',
'33080765',
'33437013',
'21400646',
'35690445',
'32615985',
'32352504',
'34127150',
'26037488',
'35481812',
'27023272',
'32355287',
'33927059',
'21356116',
'32357098',
'37876165',
'34392195',
'35113831',
'33063830',
'36127858',
'30071627',
'22358717',
'21565496',
'28367622',
'35477738',
'32357330',
'37539807',
'22885695',
'30067699',
'37539814',
'32615992',
'32352910',
'21743436',
'32994922',
'37973572',
'38180093',
'21680693',
'22499991',
'37964765',
'35481836',
'35481874',
'35043193',
'37778543',
'23342973',
'24024798',
'19602548',
'32616100',
'30070440',
'34485192',
'34540468',
'29472463',
'21504558',
'35411210',
'14309924',
'32615996',
'37877313',
'32071941',
'22465401',
'35500228',
'35256875',
'20183690',
'36026030',
'32616073',
'37774008',
'35837980',
'33301138',
'11790316',
'33301264',
'33301062',
'22242080',
'36129413',
'33554915',
'36130860',
'21743442',
'33301376',
'34631034',
'27014134',
'27722480',
'33080576',
'36279272',
'34392901',
'35681419',
'36110956',
'23417230',
'32365037',
'32071316',
'32356323',
'32609894',
'22468630',
'33425412',
'32357087',
'22044460',
'35574542',
'35481852',
'14697329',
'32068798',
'27722428',
'37539821',
'22248133',
'36130688',
'33301221',
'37990243',
'36279092',
'36131366',
'28208552',
'32355432',
'34630729',
'37876649',
'32357108',
'36279077',
'33675577',
'22247888',
'34068347',
'33088101',
'22884252',
'33675610',
'33523375',
'35481794',
'32366483',
'31352657',
'37973731',
'38093071',
'25777260',
'34631022',
'32355035',
'32067426',
'33030406',
'34495390',
'33425457',
'35680928',
'22500763',
'33926985',
'34635178',
'26043230',
'6333701',
'32365072',
'32354895',
'22097616',
'32992249',
'37728395',
'22883925',
'33675613',
'27790533',
'26056961',
'30688710',
'23342694',
'23361198',
'24711159',
'16970423',
'30332046',
'32609940',
'6390153',
'34109790',
'36127823',
'37883665',
'34630830',
'21611313',
'33680540',
'33301022',
'33088145',
'37781870',
'25638433',
'26046980',
'37270978',
'38162938',
'36279112',
'37782677',
'33425395',
'33556250',
'20977092',
'21224988',
'33425341',
'33065989',
'32082309',
'37539796',
'32156331',
'36011635',
'35284499',
'36130822',
'22885521',
'36672814',
'35015451',
'32354970',
'34068223',
'36130400',
'32616055',
'21305655',
'20425875',
'19938409',
'33433817',
'33668989',
'33081102',
'31832253',
'35681283',
'37774226',
'35840775',
'21224930',
'35284248',
'32055826',
'32227815',
'30230895',
'36279143',
'25169775',
'32357358',
'23417055',
'22464448',
'37539692',
'37500062',
'22465375',
'23049628',
'21611629',
'21611575',
'21283557',
'33556267',
'37539664',
'34068263',
'34630843',
'21680659',
'33433958',
'31344810',
'27773582',
'21191873',
'20984974',
'32357369',
'32609921',
'26095374',
'20941278',
'21328515',
'22468591',
'34096206',
'33555048',
'21504522',
'37884213',
'37727529',
'33088062',
'32609843',
'22885345',
'13770524',
'27722535',
'21225241',
'32615969',
'25777299',
'36279152',
'30070449',
'37733943',
'35681963',
'26036305',
'25781638',
'25467961',
'32045632',
'33018683',
'35682106',
'33065561',
'36129467',
'36279103',
'34630749',
'32034897',
'22247428',
'33006634',
'32071909',
'32609885',
'32365031',
'30070485',
'35477761',
'35477746',
'22886318',
'32066897',
'35489089',
'11026964',
'33660478')
group by c.job_id, j.markup), 

judgments as (select count(j.id) as judgments, count(distinct(j.unit_id)) as units, j.job_id
from public.builder_judgments j
Where j.worker_id in ('33653714'
'33081299',
'22465363',
'31668889',
'34929784',
'30764920',
'26737823',
'32356300',
'32616093',
'22886152',
'37539733',
'35275620',
'37881707',
'37729253',
'35481760',
'24590438',
'21303500',
'32609858',
'32355224',
'33064854',
'33687647',
'33927026',
'27722469',
'22500773',
'37539725',
'32354146',
'38089851',
'34325473',
'23049406',
'34631006',
'33968289',
'37883753',
'25777350',
'33653648',
'34318322',
'32616118',
'34392953',
'32357118',
'25480855',
'36130770',
'34392378',
'33362908',
'35113873',
'21305078',
'32351984',
'32365768',
'18231812',
'38019958',
'35689223',
'21680730',
'22097615',
'33434055',
'22468582',
'32033532',
'21213722',
'27722598',
'22428048',
'31914384',
'34325337',
'32814613',
'36131277',
'31832311',
'30070462',
'22884223',
'26758135',
'21743435',
'33064431',
'32616022',
'30071649',
'32352389',
'21674694',
'22222960',
'21396240',
'22050439',
'33678296',
'32357339',
'33301099',
'22885569',
'25662625',
'33675569',
'22500756',
'21703364',
'21213857',
'27722517',
'36130318',
'34630926',
'32593398',
'34630814',
'35256778',
'12530015',
'25606600',
'32365662',
'34343517',
'32616038',
'32609930',
'33081531',
'33426493',
'33301357',
'23343032',
'33081363',
'22044440',
'36130254',
'35477713',
'37876875',
'33064649',
'16880192',
'36129444',
'35284384',
'16881182',
'32616069',
'34630760',
'34392326',
'34392224',
'31668408',
'34068305',
'33523233',
'35322110',
'37737611',
'37539717',
'36129492',
'22526306',
'30070453',
'32693849',
'21504584',
'34635150',
'22044471',
'33511293',
'34318383',
'33300965',
'25480796',
'33926948',
'32587270',
'22247867',
'34392168',
'22247433',
'32365063',
'33272155',
'32081416',
'36131235',
'27886237',
'36279255',
'25777210',
'35102875',
'29472437',
'32365049',
'37884727',
'21400613',
'36130729',
'21224971',
'37709667',
'32615952',
'21283280',
'33927048',
'34550621',
'33926916',
'25480942',
'27722450',
'26758189',
'32365756',
'34233947',
'34330401',
'24198663',
'28384742',
'33568680',
'25464796',
'22045113',
'34630807',
'30071623',
'36279134',
'27722557',
'30229996',
'22082304',
'32357134',
'33668967',
'25193547',
'32463376',
'32082320',
'35488810',
'6333208',
'36215354',
'25470964',
'32365042',
'33927005',
'33568745',
'38067351',
'37539683',
'25169810',
'22247909',
'34325689',
'32365055',
'11031865',
'35681561',
'36279128',
'33678300',
'34252583',
'21504504',
'37881716',
'22247437',
'35682180',
'35636365',
'25169846',
'21209645',
'20598738',
'34630651',
'36279167',
'27033721',
'22297276',
'32365774',
'33064084',
'26546774',
'33066213',
'32609910',
'37539672',
'29545498',
'22465712',
'34112311',
'21213852',
'32357345',
'32356309',
'32365083',
'33433998',
'21384765',
'29458969',
'33066384',
'29466758',
'34392367',
'34631047',
'32404911',
'34630694',
'34392853',
'21213723',
'37778490',
'37851621',
'34318187',
'21682695',
'35284455',
'34930434',
'33301338',
'34941591',
'33568701',
'31668312',
'32082605',
'32070850',
'33065741',
'22895147',
'32356292',
'34121020',
'16858108',
'36085043',
'21400557',
'35004293',
'22044466',
'35282203',
'33425290',
'34330116',
'25467692',
'33063641',
'25482164',
'36279054',
'32082281',
'34325405',
'32356316',
'32032908',
'33080765',
'33437013',
'21400646',
'35690445',
'32615985',
'32352504',
'34127150',
'26037488',
'35481812',
'27023272',
'32355287',
'33927059',
'21356116',
'32357098',
'37876165',
'34392195',
'35113831',
'33063830',
'36127858',
'30071627',
'22358717',
'21565496',
'28367622',
'35477738',
'32357330',
'37539807',
'22885695',
'30067699',
'37539814',
'32615992',
'32352910',
'21743436',
'32994922',
'37973572',
'38180093',
'21680693',
'22499991',
'37964765',
'35481836',
'35481874',
'35043193',
'37778543',
'23342973',
'24024798',
'19602548',
'32616100',
'30070440',
'34485192',
'34540468',
'29472463',
'21504558',
'35411210',
'14309924',
'32615996',
'37877313',
'32071941',
'22465401',
'35500228',
'35256875',
'20183690',
'36026030',
'32616073',
'37774008',
'35837980',
'33301138',
'11790316',
'33301264',
'33301062',
'22242080',
'36129413',
'33554915',
'36130860',
'21743442',
'33301376',
'34631034',
'27014134',
'27722480',
'33080576',
'36279272',
'34392901',
'35681419',
'36110956',
'23417230',
'32365037',
'32071316',
'32356323',
'32609894',
'22468630',
'33425412',
'32357087',
'22044460',
'35574542',
'35481852',
'14697329',
'32068798',
'27722428',
'37539821',
'22248133',
'36130688',
'33301221',
'37990243',
'36279092',
'36131366',
'28208552',
'32355432',
'34630729',
'37876649',
'32357108',
'36279077',
'33675577',
'22247888',
'34068347',
'33088101',
'22884252',
'33675610',
'33523375',
'35481794',
'32366483',
'31352657',
'37973731',
'38093071',
'25777260',
'34631022',
'32355035',
'32067426',
'33030406',
'34495390',
'33425457',
'35680928',
'22500763',
'33926985',
'34635178',
'26043230',
'6333701',
'32365072',
'32354895',
'22097616',
'32992249',
'37728395',
'22883925',
'33675613',
'27790533',
'26056961',
'30688710',
'23342694',
'23361198',
'24711159',
'16970423',
'30332046',
'32609940',
'6390153',
'34109790',
'36127823',
'37883665',
'34630830',
'21611313',
'33680540',
'33301022',
'33088145',
'37781870',
'25638433',
'26046980',
'37270978',
'38162938',
'36279112',
'37782677',
'33425395',
'33556250',
'20977092',
'21224988',
'33425341',
'33065989',
'32082309',
'37539796',
'32156331',
'36011635',
'35284499',
'36130822',
'22885521',
'36672814',
'35015451',
'32354970',
'34068223',
'36130400',
'32616055',
'21305655',
'20425875',
'19938409',
'33433817',
'33668989',
'33081102',
'31832253',
'35681283',
'37774226',
'35840775',
'21224930',
'35284248',
'32055826',
'32227815',
'30230895',
'36279143',
'25169775',
'32357358',
'23417055',
'22464448',
'37539692',
'37500062',
'22465375',
'23049628',
'21611629',
'21611575',
'21283557',
'33556267',
'37539664',
'34068263',
'34630843',
'21680659',
'33433958',
'31344810',
'27773582',
'21191873',
'20984974',
'32357369',
'32609921',
'26095374',
'20941278',
'21328515',
'22468591',
'34096206',
'33555048',
'21504522',
'37884213',
'37727529',
'33088062',
'32609843',
'22885345',
'13770524',
'27722535',
'21225241',
'32615969',
'25777299',
'36279152',
'30070449',
'37733943',
'35681963',
'26036305',
'25781638',
'25467961',
'32045632',
'33018683',
'35682106',
'33065561',
'36129467',
'36279103',
'34630749',
'32034897',
'22247428',
'33006634',
'32071909',
'32609885',
'32365031',
'30070485',
'35477761',
'35477746',
'22886318',
'32066897',
'35489089',
'11026964',
'33660478'
)
AND j.golden = 'false'
group by j.job_id),

total_rows as (
select u.job_id, COUNT(u.id) as total_ordered_rows
From public.builder_units u
WHERE u.state IN (2, 3,4,5, 9)
GROUP BY u.job_id
),
total_cost as (
select (sum(c.amount) + (sum(c.amount) * (j.markup::numeric / 100))) as total_cost_with_markup, c.job_id
from public.builder_conversions c
join public.builder_jobs j on j.id = c.job_id
group by c.job_id, j.markup
),

total as (
select count(j.id) as normal_judgments, j.unit_id, j.job_id
from public.builder_judgments j
-- where j.job_id = 888923
where j.golden = false
group by j.unit_id, j.job_id),

scammy as (
select count(j.id) as scammy_judgments, j.unit_id, j.job_id
from public.builder_judgments j
-- where j.job_id = 888923
where j.golden = false
and j.worker_id in ('33653714'
'33081299',
'22465363',
'31668889',
'34929784',
'30764920',
'26737823',
'32356300',
'32616093',
'22886152',
'37539733',
'35275620',
'37881707',
'37729253',
'35481760',
'24590438',
'21303500',
'32609858',
'32355224',
'33064854',
'33687647',
'33927026',
'27722469',
'22500773',
'37539725',
'32354146',
'38089851',
'34325473',
'23049406',
'34631006',
'33968289',
'37883753',
'25777350',
'33653648',
'34318322',
'32616118',
'34392953',
'32357118',
'25480855',
'36130770',
'34392378',
'33362908',
'35113873',
'21305078',
'32351984',
'32365768',
'18231812',
'38019958',
'35689223',
'21680730',
'22097615',
'33434055',
'22468582',
'32033532',
'21213722',
'27722598',
'22428048',
'31914384',
'34325337',
'32814613',
'36131277',
'31832311',
'30070462',
'22884223',
'26758135',
'21743435',
'33064431',
'32616022',
'30071649',
'32352389',
'21674694',
'22222960',
'21396240',
'22050439',
'33678296',
'32357339',
'33301099',
'22885569',
'25662625',
'33675569',
'22500756',
'21703364',
'21213857',
'27722517',
'36130318',
'34630926',
'32593398',
'34630814',
'35256778',
'12530015',
'25606600',
'32365662',
'34343517',
'32616038',
'32609930',
'33081531',
'33426493',
'33301357',
'23343032',
'33081363',
'22044440',
'36130254',
'35477713',
'37876875',
'33064649',
'16880192',
'36129444',
'35284384',
'16881182',
'32616069',
'34630760',
'34392326',
'34392224',
'31668408',
'34068305',
'33523233',
'35322110',
'37737611',
'37539717',
'36129492',
'22526306',
'30070453',
'32693849',
'21504584',
'34635150',
'22044471',
'33511293',
'34318383',
'33300965',
'25480796',
'33926948',
'32587270',
'22247867',
'34392168',
'22247433',
'32365063',
'33272155',
'32081416',
'36131235',
'27886237',
'36279255',
'25777210',
'35102875',
'29472437',
'32365049',
'37884727',
'21400613',
'36130729',
'21224971',
'37709667',
'32615952',
'21283280',
'33927048',
'34550621',
'33926916',
'25480942',
'27722450',
'26758189',
'32365756',
'34233947',
'34330401',
'24198663',
'28384742',
'33568680',
'25464796',
'22045113',
'34630807',
'30071623',
'36279134',
'27722557',
'30229996',
'22082304',
'32357134',
'33668967',
'25193547',
'32463376',
'32082320',
'35488810',
'6333208',
'36215354',
'25470964',
'32365042',
'33927005',
'33568745',
'38067351',
'37539683',
'25169810',
'22247909',
'34325689',
'32365055',
'11031865',
'35681561',
'36279128',
'33678300',
'34252583',
'21504504',
'37881716',
'22247437',
'35682180',
'35636365',
'25169846',
'21209645',
'20598738',
'34630651',
'36279167',
'27033721',
'22297276',
'32365774',
'33064084',
'26546774',
'33066213',
'32609910',
'37539672',
'29545498',
'22465712',
'34112311',
'21213852',
'32357345',
'32356309',
'32365083',
'33433998',
'21384765',
'29458969',
'33066384',
'29466758',
'34392367',
'34631047',
'32404911',
'34630694',
'34392853',
'21213723',
'37778490',
'37851621',
'34318187',
'21682695',
'35284455',
'34930434',
'33301338',
'34941591',
'33568701',
'31668312',
'32082605',
'32070850',
'33065741',
'22895147',
'32356292',
'34121020',
'16858108',
'36085043',
'21400557',
'35004293',
'22044466',
'35282203',
'33425290',
'34330116',
'25467692',
'33063641',
'25482164',
'36279054',
'32082281',
'34325405',
'32356316',
'32032908',
'33080765',
'33437013',
'21400646',
'35690445',
'32615985',
'32352504',
'34127150',
'26037488',
'35481812',
'27023272',
'32355287',
'33927059',
'21356116',
'32357098',
'37876165',
'34392195',
'35113831',
'33063830',
'36127858',
'30071627',
'22358717',
'21565496',
'28367622',
'35477738',
'32357330',
'37539807',
'22885695',
'30067699',
'37539814',
'32615992',
'32352910',
'21743436',
'32994922',
'37973572',
'38180093',
'21680693',
'22499991',
'37964765',
'35481836',
'35481874',
'35043193',
'37778543',
'23342973',
'24024798',
'19602548',
'32616100',
'30070440',
'34485192',
'34540468',
'29472463',
'21504558',
'35411210',
'14309924',
'32615996',
'37877313',
'32071941',
'22465401',
'35500228',
'35256875',
'20183690',
'36026030',
'32616073',
'37774008',
'35837980',
'33301138',
'11790316',
'33301264',
'33301062',
'22242080',
'36129413',
'33554915',
'36130860',
'21743442',
'33301376',
'34631034',
'27014134',
'27722480',
'33080576',
'36279272',
'34392901',
'35681419',
'36110956',
'23417230',
'32365037',
'32071316',
'32356323',
'32609894',
'22468630',
'33425412',
'32357087',
'22044460',
'35574542',
'35481852',
'14697329',
'32068798',
'27722428',
'37539821',
'22248133',
'36130688',
'33301221',
'37990243',
'36279092',
'36131366',
'28208552',
'32355432',
'34630729',
'37876649',
'32357108',
'36279077',
'33675577',
'22247888',
'34068347',
'33088101',
'22884252',
'33675610',
'33523375',
'35481794',
'32366483',
'31352657',
'37973731',
'38093071',
'25777260',
'34631022',
'32355035',
'32067426',
'33030406',
'34495390',
'33425457',
'35680928',
'22500763',
'33926985',
'34635178',
'26043230',
'6333701',
'32365072',
'32354895',
'22097616',
'32992249',
'37728395',
'22883925',
'33675613',
'27790533',
'26056961',
'30688710',
'23342694',
'23361198',
'24711159',
'16970423',
'30332046',
'32609940',
'6390153',
'34109790',
'36127823',
'37883665',
'34630830',
'21611313',
'33680540',
'33301022',
'33088145',
'37781870',
'25638433',
'26046980',
'37270978',
'38162938',
'36279112',
'37782677',
'33425395',
'33556250',
'20977092',
'21224988',
'33425341',
'33065989',
'32082309',
'37539796',
'32156331',
'36011635',
'35284499',
'36130822',
'22885521',
'36672814',
'35015451',
'32354970',
'34068223',
'36130400',
'32616055',
'21305655',
'20425875',
'19938409',
'33433817',
'33668989',
'33081102',
'31832253',
'35681283',
'37774226',
'35840775',
'21224930',
'35284248',
'32055826',
'32227815',
'30230895',
'36279143',
'25169775',
'32357358',
'23417055',
'22464448',
'37539692',
'37500062',
'22465375',
'23049628',
'21611629',
'21611575',
'21283557',
'33556267',
'37539664',
'34068263',
'34630843',
'21680659',
'33433958',
'31344810',
'27773582',
'21191873',
'20984974',
'32357369',
'32609921',
'26095374',
'20941278',
'21328515',
'22468591',
'34096206',
'33555048',
'21504522',
'37884213',
'37727529',
'33088062',
'32609843',
'22885345',
'13770524',
'27722535',
'21225241',
'32615969',
'25777299',
'36279152',
'30070449',
'37733943',
'35681963',
'26036305',
'25781638',
'25467961',
'32045632',
'33018683',
'35682106',
'33065561',
'36129467',
'36279103',
'34630749',
'32034897',
'22247428',
'33006634',
'32071909',
'32609885',
'32365031',
'30070485',
'35477761',
'35477746',
'22886318',
'32066897',
'35489089',
'11026964',
'33660478')
group by j.unit_id, j.job_id),

total_judgments as (
select count(j.id) as total_judgments, j.job_id
from public.builder_judgments j
where j.golden = false
group by j.job_id),

all_judgments as (
select t.normal_judgments, s.scammy_judgments, s.unit_id, s.job_id,
s.scammy_judgments::numeric / t.normal_judgments::numeric AS percentage
from total t
join scammy s on s.unit_id = t.unit_id),

scammy_percent as(
select count(case when percentage > .3 then unit_id end) as rows, job_id
from all_judgments
group by job_id)

select cost as conversions_paid_to_scammy_contributors, tc.total_cost_with_markup, 
judgments as scammy_judgments, 
tj.total_judgments, 
units as rows_with_1_scammy_judgment, p.rows as rows_with_majority_scammed_judgments, 
tr.total_ordered_rows, judgments.job_id, j.title as job_title, 
a.name as team, u.email as user
from cost
join judgments on judgments.job_id = cost.job_id
join total_judgments tj on tj.job_id = judgments.job_id
join public.builder_jobs j ON j.id = judgments.job_id
join public.akon_teams a ON a.id = j.team_id
join public.builder_users u ON j.user_id = u.id
join total_rows tr ON tr.job_id = j.id
join total_cost tc ON tc.job_id = j.id 
left join scammy_percent p on p.job_id = cost.job_id
Order by judgments.judgments DESC