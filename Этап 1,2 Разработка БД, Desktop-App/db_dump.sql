--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.17
-- Dumped by pg_dump version 9.6.17

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: dt_user_auth(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.dt_user_auth(user_login character varying, user_password character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
		user_id integer;
	BEGIN
		user_id := null;
		
		SELECT du.id INTO user_id
		FROM dt_user du
		WHERE du.login = user_login AND du.password = MD5(user_password);
		
		IF user_id IS NOT null THEN
			RETURN user_id;
		ELSE
			RETURN -1;
		END IF;
		
	RETURN user_id;
	EXCEPTION
  		WHEN no_data_found THEN
    		--RAISE NOTICE 'Illegal operation: %', SQLERRM;
			RETURN -2;
	END;
$$;


ALTER FUNCTION public.dt_user_auth(user_login character varying, user_password character varying) OWNER TO postgres;

--
-- Name: dt_user_reg(character varying, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.dt_user_reg(login character varying, password character varying, firstname character varying, secondname character varying, middlename character varying, email character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
		user_id integer;
	BEGIN
		user_id := null;
		
		INSERT INTO dt_user (login, password)
		VALUES (login, MD5(password))
		RETURNING id INTO user_id;
		
		IF user_id IS NOT null THEN
			INSERT INTO personalinfo (firstname, secondname, middlename, e_mail, id_user)
			VALUES (firstName, secondName, middleName, eMail, user_id);
			RETURN 1;
		ELSE
			RETURN -1;
		END IF;
		
	RETURN user_id;
	EXCEPTION
  		WHEN unique_violation THEN
    		--RAISE NOTICE 'Illegal operation: %', SQLERRM;
			RETURN -1;
	END;
$$;


ALTER FUNCTION public.dt_user_reg(login character varying, password character varying, firstname character varying, secondname character varying, middlename character varying, email character varying) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: actmark; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.actmark (
    id integer NOT NULL,
    name character varying(10) NOT NULL,
    CONSTRAINT actmark_name CHECK (((name)::text = ANY ((ARRAY['Исправен'::character varying, 'Неисправен'::character varying])::text[])))
);


ALTER TABLE public.actmark OWNER TO postgres;

--
-- Name: booking; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.booking (
    id integer NOT NULL,
    number character varying(20) NOT NULL,
    date date NOT NULL,
    "time" time without time zone NOT NULL,
    sourceaddress character varying(200) NOT NULL,
    targetaddress character varying(200) NOT NULL,
    id_state integer NOT NULL,
    id_customer integer NOT NULL,
    id_operator integer NOT NULL,
    cost numeric(11,2) NOT NULL,
    id_transport integer
);


ALTER TABLE public.booking OWNER TO postgres;

--
-- Name: bookingstate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bookingstate (
    id integer NOT NULL,
    name character varying(11) NOT NULL,
    CONSTRAINT orderstate_name CHECK (((name)::text = ANY ((ARRAY['Активен'::character varying, 'Исполняется'::character varying, 'Отменен'::character varying, 'Выполнен'::character varying, 'Закрыт'::character varying])::text[])))
);


ALTER TABLE public.bookingstate OWNER TO postgres;

--
-- Name: completenessact; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.completenessact (
    id integer NOT NULL,
    state character varying(20) NOT NULL,
    date date NOT NULL,
    id_transport integer,
    id_mark integer
);


ALTER TABLE public.completenessact OWNER TO postgres;

--
-- Name: dt_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dt_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dt_user_id_seq OWNER TO postgres;

--
-- Name: dt_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dt_user (
    id integer DEFAULT nextval('public.dt_user_id_seq'::regclass) NOT NULL,
    login character varying(40) NOT NULL,
    password character varying(40) NOT NULL
);


ALTER TABLE public.dt_user OWNER TO postgres;

--
-- Name: faulttype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.faulttype (
    id integer NOT NULL,
    name character varying(7) NOT NULL,
    CONSTRAINT faulttype_name CHECK (((name)::text = ANY ((ARRAY['Легкая'::character varying, 'Средняя'::character varying, 'Большая'::character varying])::text[])))
);


ALTER TABLE public.faulttype OWNER TO postgres;

--
-- Name: gender; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gender (
    id integer NOT NULL,
    name character varying(20) NOT NULL,
    CONSTRAINT gender_name CHECK (((name)::text = ANY ((ARRAY['Мужской'::character varying, 'Женский'::character varying, 'Другой'::character varying])::text[])))
);


ALTER TABLE public.gender OWNER TO postgres;

--
-- Name: personalinfo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.personalinfo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.personalinfo_id_seq OWNER TO postgres;

--
-- Name: personalinfo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personalinfo (
    id integer DEFAULT nextval('public.personalinfo_id_seq'::regclass) NOT NULL,
    firstname character varying(40) NOT NULL,
    secondname character varying(50) NOT NULL,
    middlename character varying(50),
    e_mail character varying(50) NOT NULL,
    phone character varying(14),
    birthdate date,
    photolink character varying(255),
    id_user integer NOT NULL,
    id_gender integer NOT NULL
);


ALTER TABLE public.personalinfo OWNER TO postgres;

--
-- Name: repairact; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.repairact (
    id integer NOT NULL,
    id_compl_act integer NOT NULL,
    comment character varying(250),
    id_repair_type integer NOT NULL,
    id_fault_type integer NOT NULL
);


ALTER TABLE public.repairact OWNER TO postgres;

--
-- Name: repaircycle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.repaircycle (
    id integer NOT NULL
);


ALTER TABLE public.repaircycle OWNER TO postgres;

--
-- Name: repairtype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.repairtype (
    id integer NOT NULL,
    name character varying(11) NOT NULL,
    CONSTRAINT repairtype_name CHECK (((name)::text = ANY ((ARRAY['Малый'::character varying, 'Средний'::character varying, 'Капитальный'::character varying])::text[])))
);


ALTER TABLE public.repairtype OWNER TO postgres;

--
-- Name: role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role (
    id integer NOT NULL,
    systemname character varying(100) NOT NULL,
    name character varying(150) NOT NULL
);


ALTER TABLE public.role OWNER TO postgres;

--
-- Name: rolefunctions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rolefunctions (
    id integer NOT NULL,
    id_function integer NOT NULL,
    id_role integer NOT NULL
);


ALTER TABLE public.rolefunctions OWNER TO postgres;

--
-- Name: systemfunction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.systemfunction (
    id integer NOT NULL,
    systemname character varying(100) NOT NULL,
    name character varying(150) NOT NULL
);


ALTER TABLE public.systemfunction OWNER TO postgres;

--
-- Name: techinspcycle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.techinspcycle (
    id integer NOT NULL
);


ALTER TABLE public.techinspcycle OWNER TO postgres;

--
-- Name: transport; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transport (
    id integer NOT NULL,
    brandname character varying(100),
    model character varying(20),
    productionyear date,
    regnumber character varying(15),
    regdate date,
    writeoffdate date,
    id_type integer NOT NULL
);


ALTER TABLE public.transport OWNER TO postgres;

--
-- Name: transportphoto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transportphoto (
    id integer NOT NULL,
    link character varying(255),
    id_transport integer NOT NULL
);


ALTER TABLE public.transportphoto OWNER TO postgres;

--
-- Name: transporttype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transporttype (
    id integer NOT NULL,
    name character varying(10),
    CONSTRAINT transporttype_name CHECK (((name)::text = ANY ((ARRAY['Эконом'::character varying, 'Бизнес'::character varying, 'Премиум'::character varying])::text[])))
);


ALTER TABLE public.transporttype OWNER TO postgres;

--
-- Name: transportunits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transportunits (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(200),
    id_compl_act integer NOT NULL,
    id_repair integer NOT NULL,
    id_tech_insp integer NOT NULL
);


ALTER TABLE public.transportunits OWNER TO postgres;

--
-- Name: userroles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.userroles (
    id integer NOT NULL,
    id_role integer NOT NULL,
    id_user integer NOT NULL
);


ALTER TABLE public.userroles OWNER TO postgres;

--
-- Data for Name: actmark; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: booking; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: bookingstate; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: completenessact; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: dt_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.dt_user VALUES (2, 'alkardashin', 'e807f1fcf82d132f9bb018ca6738a19f');


--
-- Name: dt_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dt_user_id_seq', 2, true);


--
-- Data for Name: faulttype; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: gender; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.gender VALUES (1, 'Мужской');
INSERT INTO public.gender VALUES (2, 'Женский');
INSERT INTO public.gender VALUES (3, 'Другой');


--
-- Data for Name: personalinfo; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.personalinfo VALUES (1, 'Алексей', 'Кардашин', 'Вячеславович', 'gradei@yandex.ru', NULL, NULL, NULL, 2, 1);


--
-- Name: personalinfo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personalinfo_id_seq', 1, true);


--
-- Data for Name: repairact; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: repaircycle; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: repairtype; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.role VALUES (1, 'God', 'Бог');
INSERT INTO public.role VALUES (2, 'Admin', 'Администратор');
INSERT INTO public.role VALUES (3, 'User', 'Пользователь');


--
-- Data for Name: rolefunctions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rolefunctions VALUES (1, 1, 2);
INSERT INTO public.rolefunctions VALUES (2, 2, 2);
INSERT INTO public.rolefunctions VALUES (3, 3, 2);
INSERT INTO public.rolefunctions VALUES (4, 1, 3);
INSERT INTO public.rolefunctions VALUES (5, 1, 1);
INSERT INTO public.rolefunctions VALUES (6, 2, 1);
INSERT INTO public.rolefunctions VALUES (7, 3, 1);


--
-- Data for Name: systemfunction; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.systemfunction VALUES (1, 'Profile', 'Профиль');
INSERT INTO public.systemfunction VALUES (2, 'UserManage', 'Управление пользователями');
INSERT INTO public.systemfunction VALUES (3, 'RoleManage', 'Управление ролями');


--
-- Data for Name: techinspcycle; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: transport; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: transportphoto; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: transporttype; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: transportunits; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: userroles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.userroles VALUES (1, 2, 2);
INSERT INTO public.userroles VALUES (2, 3, 2);


--
-- Name: actmark actmark_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actmark
    ADD CONSTRAINT actmark_pkey PRIMARY KEY (id);


--
-- Name: booking booking_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_pkey PRIMARY KEY (id);


--
-- Name: bookingstate bookingstate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookingstate
    ADD CONSTRAINT bookingstate_pkey PRIMARY KEY (id);


--
-- Name: completenessact completenessact_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.completenessact
    ADD CONSTRAINT completenessact_pkey PRIMARY KEY (id);


--
-- Name: dt_user dt_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dt_user
    ADD CONSTRAINT dt_user_pkey PRIMARY KEY (id);


--
-- Name: faulttype faulttype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faulttype
    ADD CONSTRAINT faulttype_pkey PRIMARY KEY (id);


--
-- Name: gender gender_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gender
    ADD CONSTRAINT gender_pkey PRIMARY KEY (id);


--
-- Name: personalinfo personalinfo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personalinfo
    ADD CONSTRAINT personalinfo_pkey PRIMARY KEY (id);


--
-- Name: repairact repairact_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repairact
    ADD CONSTRAINT repairact_pkey PRIMARY KEY (id);


--
-- Name: repaircycle repaircycle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repaircycle
    ADD CONSTRAINT repaircycle_pkey PRIMARY KEY (id);


--
-- Name: repairtype repairtype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repairtype
    ADD CONSTRAINT repairtype_pkey PRIMARY KEY (id);


--
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- Name: rolefunctions rolefunctions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolefunctions
    ADD CONSTRAINT rolefunctions_pkey PRIMARY KEY (id);


--
-- Name: systemfunction systemfunction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.systemfunction
    ADD CONSTRAINT systemfunction_pkey PRIMARY KEY (id);


--
-- Name: techinspcycle techinspcycle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.techinspcycle
    ADD CONSTRAINT techinspcycle_pkey PRIMARY KEY (id);


--
-- Name: transport transport_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transport
    ADD CONSTRAINT transport_pkey PRIMARY KEY (id);


--
-- Name: transportphoto transportphoto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transportphoto
    ADD CONSTRAINT transportphoto_pkey PRIMARY KEY (id);


--
-- Name: transporttype transporttype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transporttype
    ADD CONSTRAINT transporttype_pkey PRIMARY KEY (id);


--
-- Name: transportunits transportunits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transportunits
    ADD CONSTRAINT transportunits_pkey PRIMARY KEY (id);


--
-- Name: userroles userroles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userroles
    ADD CONSTRAINT userroles_pkey PRIMARY KEY (id);


--
-- Name: xak1order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX xak1order ON public.booking USING btree (number, date, "time");


--
-- Name: xak1personalinfo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX xak1personalinfo ON public.personalinfo USING btree (firstname, secondname, middlename, phone);


--
-- Name: xak1user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX xak1user ON public.dt_user USING btree (login);


--
-- Name: xak2personalinfo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX xak2personalinfo ON public.personalinfo USING btree (e_mail);


--
-- Name: booking booking_id_customer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_id_customer_fkey FOREIGN KEY (id_customer) REFERENCES public.dt_user(id);


--
-- Name: booking booking_id_operator_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_id_operator_fkey FOREIGN KEY (id_operator) REFERENCES public.dt_user(id);


--
-- Name: booking booking_id_state_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_id_state_fkey FOREIGN KEY (id_state) REFERENCES public.bookingstate(id);


--
-- Name: booking booking_id_transport_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_id_transport_fkey FOREIGN KEY (id_transport) REFERENCES public.transport(id);


--
-- Name: completenessact completenessact_id_mark_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.completenessact
    ADD CONSTRAINT completenessact_id_mark_fkey FOREIGN KEY (id_mark) REFERENCES public.actmark(id);


--
-- Name: completenessact completenessact_id_transport_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.completenessact
    ADD CONSTRAINT completenessact_id_transport_fkey FOREIGN KEY (id_transport) REFERENCES public.transport(id);


--
-- Name: personalinfo personalinfo_id_gender_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personalinfo
    ADD CONSTRAINT personalinfo_id_gender_fkey FOREIGN KEY (id_gender) REFERENCES public.gender(id);


--
-- Name: personalinfo personalinfo_id_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personalinfo
    ADD CONSTRAINT personalinfo_id_user_fkey FOREIGN KEY (id_user) REFERENCES public.dt_user(id);


--
-- Name: repairact repairact_id_compl_act_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repairact
    ADD CONSTRAINT repairact_id_compl_act_fkey FOREIGN KEY (id_compl_act) REFERENCES public.completenessact(id);


--
-- Name: repairact repairact_id_fault_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repairact
    ADD CONSTRAINT repairact_id_fault_type_fkey FOREIGN KEY (id_fault_type) REFERENCES public.faulttype(id);


--
-- Name: repairact repairact_id_repair_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repairact
    ADD CONSTRAINT repairact_id_repair_type_fkey FOREIGN KEY (id_repair_type) REFERENCES public.repairtype(id);


--
-- Name: rolefunctions rolefunctions_id_function_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolefunctions
    ADD CONSTRAINT rolefunctions_id_function_fkey FOREIGN KEY (id_function) REFERENCES public.systemfunction(id);


--
-- Name: rolefunctions rolefunctions_id_role_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rolefunctions
    ADD CONSTRAINT rolefunctions_id_role_fkey FOREIGN KEY (id_role) REFERENCES public.role(id);


--
-- Name: transport transport_id_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transport
    ADD CONSTRAINT transport_id_type_fkey FOREIGN KEY (id_type) REFERENCES public.transporttype(id);


--
-- Name: transportphoto transportphoto_id_transport_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transportphoto
    ADD CONSTRAINT transportphoto_id_transport_fkey FOREIGN KEY (id_transport) REFERENCES public.transport(id);


--
-- Name: transportunits transportunits_id_compl_act_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transportunits
    ADD CONSTRAINT transportunits_id_compl_act_fkey FOREIGN KEY (id_compl_act) REFERENCES public.completenessact(id);


--
-- Name: transportunits transportunits_id_repair_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transportunits
    ADD CONSTRAINT transportunits_id_repair_fkey FOREIGN KEY (id_repair) REFERENCES public.techinspcycle(id);


--
-- Name: transportunits transportunits_id_tech_insp_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transportunits
    ADD CONSTRAINT transportunits_id_tech_insp_fkey FOREIGN KEY (id_tech_insp) REFERENCES public.repaircycle(id);


--
-- Name: userroles userroles_id_role_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userroles
    ADD CONSTRAINT userroles_id_role_fkey FOREIGN KEY (id_role) REFERENCES public.role(id);


--
-- Name: userroles userroles_id_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userroles
    ADD CONSTRAINT userroles_id_user_fkey FOREIGN KEY (id_user) REFERENCES public.dt_user(id);


--
-- PostgreSQL database dump complete
--

