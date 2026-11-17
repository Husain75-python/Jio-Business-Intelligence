--
-- PostgreSQL database dump
--

\restrict GuToAt1Kd8bnI0fRCtV6AupHuCxjYmYM58NxU6dO32MtZ27CXsbFxkvRl68rwEb

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

-- Started on 2026-11-17 23:00:20

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 16409)
-- Name: dim_entity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dim_entity (
    entity_id bigint NOT NULL,
    entity_code character varying(20) NOT NULL,
    entity_name character varying(150) NOT NULL,
    entity_type character varying(30) NOT NULL,
    country_code character(2) DEFAULT 'IN'::bpchar,
    is_primary boolean DEFAULT false,
    notes text
);


ALTER TABLE public.dim_entity OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16408)
-- Name: dim_entity_entity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.dim_entity ALTER COLUMN entity_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.dim_entity_entity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 224 (class 1259 OID 16441)
-- Name: dim_metric; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dim_metric (
    metric_id bigint NOT NULL,
    metric_code character varying(50) NOT NULL,
    metric_name character varying(150) NOT NULL,
    metric_category character varying(50) NOT NULL,
    unit character varying(40) NOT NULL,
    aggregation_rule character varying(20) NOT NULL,
    description text,
    CONSTRAINT dim_metric_aggregation_rule_check CHECK (((aggregation_rule)::text = ANY ((ARRAY['sum'::character varying, 'average'::character varying, 'end_of_period'::character varying, 'ratio'::character varying, 'none'::character varying])::text[])))
);


ALTER TABLE public.dim_metric OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16440)
-- Name: dim_metric_metric_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.dim_metric ALTER COLUMN metric_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.dim_metric_metric_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 222 (class 1259 OID 16425)
-- Name: dim_period; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dim_period (
    period_id bigint NOT NULL,
    period_code character varying(20) NOT NULL,
    financial_year character varying(9) NOT NULL,
    period_type character varying(10) NOT NULL,
    period_number smallint,
    start_date date NOT NULL,
    end_date date NOT NULL,
    CONSTRAINT dim_period_check CHECK ((end_date >= start_date)),
    CONSTRAINT dim_period_period_type_check CHECK (((period_type)::text = ANY ((ARRAY['annual'::character varying, 'quarterly'::character varying, 'monthly'::character varying])::text[])))
);


ALTER TABLE public.dim_period OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16424)
-- Name: dim_period_period_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.dim_period ALTER COLUMN period_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.dim_period_period_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 228 (class 1259 OID 16471)
-- Name: fact_metric; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fact_metric (
    fact_id bigint NOT NULL,
    entity_id bigint NOT NULL,
    period_id bigint NOT NULL,
    metric_id bigint NOT NULL,
    source_id bigint NOT NULL,
    reporting_basis character varying(20) DEFAULT 'not_applicable'::character varying NOT NULL,
    value_numeric numeric(24,6) NOT NULL,
    currency_code character(3),
    geography character varying(100) DEFAULT 'India'::character varying,
    observation_status character varying(20) DEFAULT 'reported'::character varying NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fact_metric_observation_status_check CHECK (((observation_status)::text = ANY ((ARRAY['reported'::character varying, 'estimated'::character varying])::text[]))),
    CONSTRAINT fact_metric_reporting_basis_check CHECK (((reporting_basis)::text = ANY ((ARRAY['standalone'::character varying, 'consolidated'::character varying, 'not_applicable'::character varying])::text[])))
);


ALTER TABLE public.fact_metric OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16470)
-- Name: fact_metric_fact_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.fact_metric ALTER COLUMN fact_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fact_metric_fact_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 226 (class 1259 OID 16458)
-- Name: source_reference; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.source_reference (
    source_id bigint NOT NULL,
    source_org character varying(150) NOT NULL,
    source_title text NOT NULL,
    source_url text NOT NULL,
    document_date date,
    accessed_at date DEFAULT CURRENT_DATE,
    page_reference character varying(100),
    source_notes text
);


ALTER TABLE public.source_reference OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16457)
-- Name: source_reference_source_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.source_reference ALTER COLUMN source_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.source_reference_source_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 230 (class 1259 OID 16519)
-- Name: vw_jio_financial_growth; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_jio_financial_growth AS
 WITH metric_values AS (
         SELECT p.financial_year,
            p.start_date,
            m.metric_code,
            f.value_numeric AS current_value,
            lag(f.value_numeric) OVER (PARTITION BY m.metric_code ORDER BY p.start_date) AS previous_value
           FROM (((public.fact_metric f
             JOIN public.dim_entity e ON ((f.entity_id = e.entity_id)))
             JOIN public.dim_period p ON ((f.period_id = p.period_id)))
             JOIN public.dim_metric m ON ((f.metric_id = m.metric_id)))
          WHERE (((e.entity_code)::text = 'RJIL'::text) AND ((f.reporting_basis)::text = 'standalone'::text) AND ((m.metric_code)::text = ANY ((ARRAY['REVENUE'::character varying, 'PAT'::character varying])::text[])))
        )
 SELECT financial_year,
    start_date,
    metric_code,
    current_value,
    previous_value,
        CASE
            WHEN ((previous_value IS NULL) OR (previous_value <= (0)::numeric)) THEN NULL::numeric
            ELSE round((((current_value - previous_value) / previous_value) * (100)::numeric), 2)
        END AS growth_percentage
   FROM metric_values;


ALTER VIEW public.vw_jio_financial_growth OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16514)
-- Name: vw_jio_financial_performance; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_jio_financial_performance AS
 SELECT e.entity_code,
    e.entity_name,
    p.financial_year,
    p.start_date,
    m.metric_code,
    m.metric_name,
    f.value_numeric AS value,
    m.unit,
    f.reporting_basis,
    f.observation_status,
    s.source_title,
    s.source_url
   FROM ((((public.fact_metric f
     JOIN public.dim_entity e ON ((f.entity_id = e.entity_id)))
     JOIN public.dim_period p ON ((f.period_id = p.period_id)))
     JOIN public.dim_metric m ON ((f.metric_id = m.metric_id)))
     JOIN public.source_reference s ON ((f.source_id = s.source_id)))
  WHERE (((e.entity_code)::text = 'RJIL'::text) AND ((f.reporting_basis)::text = 'standalone'::text));


ALTER VIEW public.vw_jio_financial_performance OWNER TO postgres;

--
-- TOC entry 5068 (class 0 OID 16409)
-- Dependencies: 220
-- Data for Name: dim_entity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dim_entity (entity_id, entity_code, entity_name, entity_type, country_code, is_primary, notes) FROM stdin;
1	RJIL	Reliance Jio Infocomm Limited	telecom_operator	IN	t	Primary telecom reporting entity
2	JPL	Jio Platforms Limited	digital_platform	IN	f	Separate digital platform reporting entity
3	RIL	Reliance Industries Limited	parent_company	IN	f	Parent company reporting entity
4	AIRTEL	Bharti Airtel Limited	telecom_operator	IN	f	Telecom competitor
\.


--
-- TOC entry 5072 (class 0 OID 16441)
-- Dependencies: 224
-- Data for Name: dim_metric; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dim_metric (metric_id, metric_code, metric_name, metric_category, unit, aggregation_rule, description) FROM stdin;
1	REVENUE	Revenue	Financial	INR crore	sum	Reported revenue
2	EBITDA	EBITDA	Financial	INR crore	sum	Earnings before interest, taxes, depreciation and amortisation
3	PAT	Profit After Tax	Financial	INR crore	sum	Reported profit after tax
4	SUBSCRIBERS	Total Subscribers	Telecom	million	end_of_period	Total subscriber base at reporting period end
5	NET_ADDITIONS	Net Subscriber Additions	Telecom	million	sum	Net subscriber additions during reporting period
6	ARPU	Average Revenue Per User	Telecom	INR per subscriber per month	average	Reported ARPU
7	MARKET_SHARE	Subscriber Market Share	Market	percentage	end_of_period	Subscriber market share
8	DATA_TRAFFIC	Total Data Traffic	Network	PB	sum	Total reported data traffic
9	DATA_USAGE	Average Data Consumption	Network	GB per subscriber per month	average	Average monthly data consumption
10	NETWORK_4G	4G Network Coverage	Network	percentage	end_of_period	Reported 4G network coverage
11	NETWORK_5G	5G Network Coverage	Network	percentage	end_of_period	Reported 5G network coverage
\.


--
-- TOC entry 5070 (class 0 OID 16425)
-- Dependencies: 222
-- Data for Name: dim_period; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dim_period (period_id, period_code, financial_year, period_type, period_number, start_date, end_date) FROM stdin;
1	FY2016-17	2016-17	annual	\N	2016-04-01	2017-03-31
2	FY2017-18	2017-18	annual	\N	2017-04-01	2018-03-31
3	FY2018-19	2018-19	annual	\N	2018-04-01	2019-03-31
4	FY2019-20	2019-20	annual	\N	2019-04-01	2020-03-31
5	FY2020-21	2020-21	annual	\N	2020-04-01	2021-03-31
6	FY2021-22	2021-22	annual	\N	2021-04-01	2022-03-31
7	FY2022-23	2022-23	annual	\N	2022-04-01	2023-03-31
8	FY2023-24	2023-24	annual	\N	2023-04-01	2024-03-31
9	FY2024-25	2024-25	annual	\N	2024-04-01	2025-03-31
10	FY2025-26	2025-26	annual	\N	2025-04-01	2026-03-31
\.


--
-- TOC entry 5076 (class 0 OID 16471)
-- Dependencies: 228
-- Data for Name: fact_metric; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fact_metric (fact_id, entity_id, period_id, metric_id, source_id, reporting_basis, value_numeric, currency_code, geography, observation_status, notes, created_at) FROM stdin;
1	1	8	3	5	standalone	20466.000000	INR	India	reported	Profit after tax; INR crore	2026-11-10 21:01:20.477814+05:30
2	1	8	1	5	standalone	100119.000000	INR	India	reported	Revenue from operations; INR crore	2026-11-10 21:01:20.477814+05:30
3	1	9	3	5	standalone	24795.000000	INR	India	reported	Profit after tax; INR crore	2026-11-10 21:01:20.477814+05:30
4	1	9	1	5	standalone	114141.000000	INR	India	reported	Revenue from operations; INR crore	2026-11-10 21:01:20.477814+05:30
5	1	5	1	6	standalone	69888.000000	INR	India	reported	FY2020-21 comparative; unaudited; Amount in INR crore	2026-11-11 16:34:23.279922+05:30
6	1	5	3	6	standalone	12015.000000	INR	India	reported	FY2020-21 comparative; unaudited; Amount in INR crore	2026-11-11 16:34:23.279922+05:30
7	1	6	1	6	standalone	76977.000000	INR	India	reported	Audited standalone financial result; Amount in INR crore	2026-11-11 16:34:23.279922+05:30
8	1	6	3	6	standalone	14817.000000	INR	India	reported	Audited standalone financial result; Amount in INR crore	2026-11-11 16:34:23.279922+05:30
9	1	7	1	7	standalone	90786.000000	INR	India	reported	Audited standalone financial result; Amount in INR crore	2026-11-11 16:34:23.279922+05:30
10	1	7	3	7	standalone	18207.000000	INR	India	reported	Audited standalone financial result; Amount in INR crore	2026-11-11 16:34:23.279922+05:30
13	1	2	3	8	standalone	723.000000	INR	India	reported	FY2017-18 reported profit; Amount in INR crore	2026-11-11 16:43:01.503995+05:30
14	1	2	1	8	standalone	20154.000000	INR	India	reported	FY2017-18 reported revenue; Amount in INR crore	2026-11-11 16:43:01.503995+05:30
12	1	1	1	8	standalone	0.020000	INR	India	reported	FY2016-17 comparative; converted from INR lakh to INR crore	2026-11-11 16:43:01.503995+05:30
11	1	1	3	8	standalone	-0.313700	INR	India	reported	FY2016-17 comparative; converted from INR lakh to INR crore	2026-11-11 16:43:01.503995+05:30
15	1	3	1	9	standalone	40663.000000	INR	India	reported	Audited revenue from operations; INR crore. Investor presentation separately reports operating revenue of INR 38,838 crore.	2026-11-11 16:46:42.503228+05:30
16	1	3	3	9	standalone	2964.000000	INR	India	reported	Audited profit for the year; INR crore.	2026-11-11 16:46:42.503228+05:30
19	1	4	1	9	standalone	54316.000000	INR	India	reported	FY2019-20 audited standalone revenue from operations; INR crore	2026-11-11 16:50:53.578516+05:30
20	1	4	3	9	standalone	5562.000000	INR	India	reported	FY2019-20 audited standalone profit for the year; INR crore	2026-11-11 16:50:53.578516+05:30
21	1	10	1	10	standalone	128871.000000	INR	India	reported	Audited revenue from operations; gross value of services INR 151623 crore less GST recovered INR 22752 crore; INR crore	2026-11-11 16:58:45.473651+05:30
22	1	10	3	10	standalone	28173.000000	INR	India	reported	Audited profit for the year; PBT INR 37842 crore less deferred tax expenses INR 9669 crore; INR crore	2026-11-11 16:58:45.473651+05:30
\.


--
-- TOC entry 5074 (class 0 OID 16458)
-- Dependencies: 226
-- Data for Name: source_reference; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.source_reference (source_id, source_org, source_title, source_url, document_date, accessed_at, page_reference, source_notes) FROM stdin;
1	Reliance Jio	Official Jio Financial Statements	https://www.jio.com/about/investor-relations/financials/financials-statements/	\N	2026-11-10	\N	Verify RJIL and JPL reporting entity and standalone/consolidated basis separately
2	TRAI	Telecom Subscription and Performance Reports	https://www.trai.gov.in/	\N	2026-11-10	\N	Official telecom subscriber, ARPU and market performance publications
3	Reliance Industries	Annual Reports	https://www.ril.com/investors/financial-reporting	\N	2026-11-10	\N	Parent-company annual reports and separately identified segment disclosures
4	Bharti Airtel	Annual Reports and Financial Results	https://www.airtel.in/about-bharti/equity/results	\N	2026-11-10	\N	Competitor financial and operational disclosures
5	Reliance Jio Infocomm Limited	Audited Standalone Financial Statements FY2024-25	https://www.ril.com/sites/default/files/2025-08/Reliance_Jio_Infocomm_Limited.pdf	2025-04-24	2026-11-10	Standalone Statement of Profit and Loss, printed page 12	Audited RJIL standalone financial statements; includes FY2023-24 comparative figures; amounts in INR crore
6	Reliance Jio Infocomm Limited	RJIL Annual Report FY2021-22 – Standalone Financial Results	https://rilstaticasset.akamaized.net/sites/default/files/2023-01/annual-report-of-fy-2021-22.pdf	\N	2026-11-11	Board Report, printed page 3	Standalone financial results. FY2020-21 comparative figures are explicitly marked unaudited.
7	Reliance Jio Infocomm Limited	RJIL Standalone Financial Statements FY2023-24	https://www.ril.com/sites/default/files/2024-08/Reliance-Jio-Infocomm-Limited.pdf	\N	2026-11-11	Standalone Statement of Profit and Loss, printed page 13	Audited standalone financial statements; includes FY2022-23 comparative figures.
8	Reliance Jio Infocomm Limited	RJIL Annual Report FY2017-18 – Standalone Financial Statements	https://rilstaticasset.akamaized.net/sites/default/files/2023-02/Reliance%20Jio%20Infocomm%20Limited4.pdf	\N	2026-11-11	Standalone Statement of Profit and Loss	Audited standalone statements; includes FY2016-17 comparative figures
9	Reliance Jio Infocomm Limited	RJIL Annual Report FY2019-20 – Standalone Financial Statements	https://jep-asset.akamaized.net/jio/investor-relations-debenture/rjil/other-documents/annual-report-of-fy-19-20.pdf	\N	2026-11-11	Standalone Statement of Profit and Loss, printed page 38	Audited standalone financial statements; includes FY2018-19 comparative figures
10	Reliance Jio Infocomm Limited	Audited Standalone Financial Statements FY2025-26	https://www.jio.com/about/investor-relations/financials/financials-statements/	\N	2026-11-11	Standalone Statement of Profit and Loss	Audited RJIL standalone financial statements for year ended 31 March 2026. Figures verified against official statement.
\.


--
-- TOC entry 5082 (class 0 OID 0)
-- Dependencies: 219
-- Name: dim_entity_entity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dim_entity_entity_id_seq', 4, true);


--
-- TOC entry 5083 (class 0 OID 0)
-- Dependencies: 223
-- Name: dim_metric_metric_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dim_metric_metric_id_seq', 11, true);


--
-- TOC entry 5084 (class 0 OID 0)
-- Dependencies: 221
-- Name: dim_period_period_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dim_period_period_id_seq', 10, true);


--
-- TOC entry 5085 (class 0 OID 0)
-- Dependencies: 227
-- Name: fact_metric_fact_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fact_metric_fact_id_seq', 22, true);


--
-- TOC entry 5086 (class 0 OID 0)
-- Dependencies: 225
-- Name: source_reference_source_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.source_reference_source_id_seq', 10, true);


--
-- TOC entry 4897 (class 2606 OID 16423)
-- Name: dim_entity dim_entity_entity_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_entity
    ADD CONSTRAINT dim_entity_entity_code_key UNIQUE (entity_code);


--
-- TOC entry 4899 (class 2606 OID 16421)
-- Name: dim_entity dim_entity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_entity
    ADD CONSTRAINT dim_entity_pkey PRIMARY KEY (entity_id);


--
-- TOC entry 4905 (class 2606 OID 16456)
-- Name: dim_metric dim_metric_metric_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_metric
    ADD CONSTRAINT dim_metric_metric_code_key UNIQUE (metric_code);


--
-- TOC entry 4907 (class 2606 OID 16454)
-- Name: dim_metric dim_metric_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_metric
    ADD CONSTRAINT dim_metric_pkey PRIMARY KEY (metric_id);


--
-- TOC entry 4901 (class 2606 OID 16439)
-- Name: dim_period dim_period_period_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_period
    ADD CONSTRAINT dim_period_period_code_key UNIQUE (period_code);


--
-- TOC entry 4903 (class 2606 OID 16437)
-- Name: dim_period dim_period_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_period
    ADD CONSTRAINT dim_period_pkey PRIMARY KEY (period_id);


--
-- TOC entry 4911 (class 2606 OID 16491)
-- Name: fact_metric fact_metric_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_metric
    ADD CONSTRAINT fact_metric_pkey PRIMARY KEY (fact_id);


--
-- TOC entry 4909 (class 2606 OID 16469)
-- Name: source_reference source_reference_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.source_reference
    ADD CONSTRAINT source_reference_pkey PRIMARY KEY (source_id);


--
-- TOC entry 4913 (class 2606 OID 16493)
-- Name: fact_metric uq_fact_observation; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_metric
    ADD CONSTRAINT uq_fact_observation UNIQUE (entity_id, period_id, metric_id, reporting_basis, source_id, geography);


--
-- TOC entry 4914 (class 2606 OID 16494)
-- Name: fact_metric fact_metric_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_metric
    ADD CONSTRAINT fact_metric_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES public.dim_entity(entity_id);


--
-- TOC entry 4915 (class 2606 OID 16504)
-- Name: fact_metric fact_metric_metric_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_metric
    ADD CONSTRAINT fact_metric_metric_id_fkey FOREIGN KEY (metric_id) REFERENCES public.dim_metric(metric_id);


--
-- TOC entry 4916 (class 2606 OID 16499)
-- Name: fact_metric fact_metric_period_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_metric
    ADD CONSTRAINT fact_metric_period_id_fkey FOREIGN KEY (period_id) REFERENCES public.dim_period(period_id);


--
-- TOC entry 4917 (class 2606 OID 16509)
-- Name: fact_metric fact_metric_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_metric
    ADD CONSTRAINT fact_metric_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source_reference(source_id);


-- Completed on 2026-11-17 23:00:20

--
-- PostgreSQL database dump complete
--

\unrestrict GuToAt1Kd8bnI0fRCtV6AupHuCxjYmYM58NxU6dO32MtZ27CXsbFxkvRl68rwEb

