
CREATE TABLE ActMark
(
	ID                   INTEGER NOT NULL,
	Name                 VARCHAR(10) NOT NULL CONSTRAINT ActMark_Name CHECK ( Name IN ('Исправен', 'Неисправен') )
);



ALTER TABLE ActMark
ADD PRIMARY KEY (ID);



CREATE TABLE Booking
(
	ID                   INTEGER NOT NULL,
	Number               VARCHAR(20) NOT NULL,
	Date                 DATE NOT NULL,
	Time                 TIME NOT NULL,
	SourceAddress        VARCHAR(200) NOT NULL,
	TargetAddress        VARCHAR(200) NOT NULL,
	ID_state             INTEGER NOT NULL,
	ID_customer          INTEGER NOT NULL,
	ID_operator          INTEGER NOT NULL,
	Cost                 NUMERIC(11,2) NOT NULL,
	ID_transport         INTEGER NULL
);



ALTER TABLE Booking
ADD PRIMARY KEY (ID);



CREATE UNIQUE INDEX XAK1Order ON Booking
(
	Number,
	Date,
	Time
);



CREATE TABLE BookingState
(
	ID                   INTEGER NOT NULL,
	Name                 VARCHAR(11) NOT NULL CONSTRAINT OrderState_Name CHECK ( Name IN ('Активен', 'Исполняется', 'Отменен', 'Выполнен', 'Закрыт') )
);



ALTER TABLE BookingState
ADD PRIMARY KEY (ID);



CREATE TABLE CompletenessAct
(
	ID                   INTEGER NOT NULL,
	State                VARCHAR(20) NOT NULL,
	Date                 DATE NOT NULL,
	ID_transport         INTEGER NULL,
	ID_mark              INTEGER NULL
);



ALTER TABLE CompletenessAct
ADD PRIMARY KEY (ID);



CREATE TABLE FaultType
(
	ID                   INTEGER NOT NULL,
	Name                 VARCHAR(7) NOT NULL CONSTRAINT FaultType_Name CHECK ( Name IN ('Легкая', 'Средняя', 'Большая') )
);



ALTER TABLE FaultType
ADD PRIMARY KEY (ID);



CREATE TABLE Gender
(
	ID                   INTEGER NOT NULL,
	Name                 VARCHAR(20) NOT NULL CONSTRAINT Gender_Name CHECK ( Name IN ('Мужской', 'Женский', 'Другой') )
);



ALTER TABLE Gender
ADD PRIMARY KEY (ID);



CREATE TABLE PersonalInfo
(
	ID                   INTEGER NOT NULL,
	FirstName            VARCHAR(40) NOT NULL,
	SecondName           VARCHAR(50) NOT NULL,
	MiddleName           VARCHAR(50) NULL,
	E_mail               VARCHAR(50) NOT NULL,
	Phone                VARCHAR(11) NOT NULL,
	BirthDate            DATE NOT NULL,
	PhotoLink            VARCHAR(255) NOT NULL,
	ID_user              INTEGER NOT NULL,
	ID_gender            INTEGER NOT NULL
);



ALTER TABLE PersonalInfo
ADD PRIMARY KEY (ID);



CREATE UNIQUE INDEX XAK1PersonalInfo ON PersonalInfo
(
	FirstName,
	SecondName,
	MiddleName,
	Phone
);



CREATE UNIQUE INDEX XAK2PersonalInfo ON PersonalInfo
(
	E_mail
);



CREATE TABLE RepairAct
(
	ID                   INTEGER NOT NULL,
	ID_compl_act         INTEGER NOT NULL,
	Comment              VARCHAR(250) NULL,
	ID_repair_type       INTEGER NOT NULL,
	ID_fault_type        INTEGER NOT NULL
);



ALTER TABLE RepairAct
ADD PRIMARY KEY (ID);



CREATE TABLE RepairCycle
(
	ID                   INTEGER NOT NULL
);



ALTER TABLE RepairCycle
ADD PRIMARY KEY (ID);



CREATE TABLE RepairType
(
	ID                   INTEGER NOT NULL,
	Name                 VARCHAR(11) NOT NULL CONSTRAINT RepairType_Name CHECK ( Name IN ('Малый', 'Средний', 'Капитальный') )
);



ALTER TABLE RepairType
ADD PRIMARY KEY (ID);



CREATE TABLE Role
(
	ID                   INTEGER NOT NULL,
	SystemName           VARCHAR(100) NOT NULL,
	Name                 VARCHAR(150) NOT NULL
);



ALTER TABLE Role
ADD PRIMARY KEY (ID);



CREATE TABLE RoleFunctions
(
	ID                   INTEGER NOT NULL,
	ID_function          INTEGER NOT NULL,
	ID_role              INTEGER NOT NULL
);



ALTER TABLE RoleFunctions
ADD PRIMARY KEY (ID);



CREATE TABLE SystemFunction
(
	ID                   INTEGER NOT NULL,
	SystemName           VARCHAR(100) NOT NULL,
	Name                 VARCHAR(150) NOT NULL
);



ALTER TABLE SystemFunction
ADD PRIMARY KEY (ID);



CREATE TABLE TechInspCycle
(
	ID                   INTEGER NOT NULL
);



ALTER TABLE TechInspCycle
ADD PRIMARY KEY (ID);



CREATE TABLE Transport
(
	ID                   INTEGER NOT NULL,
	BrandName            VARCHAR(100) NULL,
	Model                VARCHAR(20) NULL,
	ProductionYear       DATE NULL,
	RegNumber            VARCHAR(15) NULL,
	RegDate              DATE NULL,
	WriteOffDate         DATE NULL,
	ID_type              INTEGER NOT NULL
);



ALTER TABLE Transport
ADD PRIMARY KEY (ID);



CREATE TABLE TransportPhoto
(
	ID                   INTEGER NOT NULL,
	Link                 VARCHAR(255) NULL,
	ID_transport         INTEGER NOT NULL
);



ALTER TABLE TransportPhoto
ADD PRIMARY KEY (ID);



CREATE TABLE TransportType
(
	ID                   INTEGER NOT NULL,
	Name                 VARCHAR(10) NULL CONSTRAINT TransportType_Name CHECK ( Name IN ('Эконом', 'Бизнес', 'Премиум') )
);



ALTER TABLE TransportType
ADD PRIMARY KEY (ID);



CREATE TABLE TransportUnits
(
	ID                   INTEGER NOT NULL,
	Name                 VARCHAR(50) NOT NULL,
	Description          VARCHAR(200) NULL,
	ID_compl_act         INTEGER NOT NULL,
	ID_repair            INTEGER NOT NULL,
	ID_tech_insp         INTEGER NOT NULL
);



ALTER TABLE TransportUnits
ADD PRIMARY KEY (ID);



CREATE TABLE DT_User
(
	ID                   INTEGER NOT NULL,
	Login                VARCHAR(40) NOT NULL,
	Password             VARCHAR(40) NOT NULL
);



ALTER TABLE DT_User
ADD PRIMARY KEY (ID);



CREATE UNIQUE INDEX XAK1User ON DT_User
(
	Login
);



CREATE TABLE UserRoles
(
	ID                   INTEGER NOT NULL,
	ID_role              INTEGER NOT NULL,
	ID_user              INTEGER NOT NULL
);



ALTER TABLE UserRoles
ADD PRIMARY KEY (ID);



ALTER TABLE Booking
ADD FOREIGN KEY (ID_state) REFERENCES BookingState (ID);



ALTER TABLE Booking
ADD FOREIGN KEY (ID_customer) REFERENCES DT_User (ID);



ALTER TABLE Booking
ADD FOREIGN KEY (ID_operator) REFERENCES DT_User (ID);



ALTER TABLE Booking
ADD FOREIGN KEY (ID_transport) REFERENCES Transport (ID);



ALTER TABLE CompletenessAct
ADD FOREIGN KEY (ID_transport) REFERENCES Transport (ID);



ALTER TABLE CompletenessAct
ADD FOREIGN KEY (ID_mark) REFERENCES ActMark (ID);



ALTER TABLE PersonalInfo
ADD FOREIGN KEY (ID_user) REFERENCES DT_User (ID);



ALTER TABLE PersonalInfo
ADD FOREIGN KEY (ID_gender) REFERENCES Gender (ID);



ALTER TABLE RepairAct
ADD FOREIGN KEY (ID_compl_act) REFERENCES CompletenessAct (ID);



ALTER TABLE RepairAct
ADD FOREIGN KEY (ID_repair_type) REFERENCES RepairType (ID);



ALTER TABLE RepairAct
ADD FOREIGN KEY (ID_fault_type) REFERENCES FaultType (ID);



ALTER TABLE RoleFunctions
ADD FOREIGN KEY (ID_function) REFERENCES SystemFunction (ID);



ALTER TABLE RoleFunctions
ADD FOREIGN KEY (ID_role) REFERENCES Role (ID);



ALTER TABLE Transport
ADD FOREIGN KEY (ID_type) REFERENCES TransportType (ID);



ALTER TABLE TransportPhoto
ADD FOREIGN KEY (ID_transport) REFERENCES Transport (ID);



ALTER TABLE TransportUnits
ADD FOREIGN KEY (ID_compl_act) REFERENCES CompletenessAct (ID);



ALTER TABLE TransportUnits
ADD FOREIGN KEY (ID_repair) REFERENCES TechInspCycle (ID);



ALTER TABLE TransportUnits
ADD FOREIGN KEY (ID_tech_insp) REFERENCES RepairCycle (ID);



ALTER TABLE UserRoles
ADD FOREIGN KEY (ID_role) REFERENCES Role (ID);



ALTER TABLE UserRoles
ADD FOREIGN KEY (ID_user) REFERENCES DT_User (ID);


