CREATE TABLE usuario (
	u_id 				SERIAL				NOT NULL,
	cpf				INTEGER				UNIQUE		NOT NULL,
	senha				VARCHAR(10)			NOT NULL,
	u_nome				VARCHAR(30)			NOT NULL,
	data_nascimento			DATE				NOT NULL,
	idade				INTEGER, 
	email				VARCHAR(30)			UNIQUE		NOT NULL,
	meet_rank			VARCHAR(15),
	u_pontos			DOUBLE PRECISION	DEFAULT 0,
	numero_ref			INTEGER,
	rua_ref				VARCHAR(30),
	cep_ref				INTEGER,
	latitude_ref			DOUBLE PRECISION,
	longitude_ref			DOUBLE PRECISION,
	
	CONSTRAINT usuario_pk
		PRIMARY KEY (u_id)
);

CREATE TABLE encontro (
	e_id				SERIAL				NOT NULL,
	e_data				DATE				NOT NULL,
	e_nome				TEXT				NOT NULL,
	e_tema				VARCHAR(15)			NOT NULL,
	e_descricao			TEXT				NOT NULL,
	
	CONSTRAINT encontro_pk
		PRIMARY KEY (e_id)
);

CREATE TABLE localidade (
	l_id				SERIAL				NOT NULL,
	numero_ref			INTEGER,
	rua_end				VARCHAR(30)			NOT NULL,
	cep_end				INTEGER				NOT NULL,
	latitude_end			DOUBLE PRECISION	NOT NULL,
	longitude_end			DOUBLE PRECISION	NOT NULL,
	acess_fisica			BOOLEAN,
	acess_visual			BOOLEAN,
	acess_auditiva			BOOLEAN,
	
	CONSTRAINT localidade_pk
		PRIMARY KEY (l_id)
);

CREATE TABLE participa (
	u_id				SERIAL 				NOT NULL,
	e_id				SERIAL 				NOT NULL,
	
	CONSTRAINT participa_pk
		PRIMARY KEY (u_id, e_id),
	
	CONSTRAINT participa_fk1
		FOREIGN KEY (u_id) REFERENCES usuario (u_id)
			ON UPDATE CASCADE
			ON DELETE CASCADE,
	
	CONSTRAINT participa_fk2
		FOREIGN KEY (e_id) REFERENCES encontro (e_id)
			ON UPDATE CASCADE
			ON DELETE CASCADE
);

CREATE TABLE historico (
	u_id				SERIAL 				NOT NULL,
	e_id				SERIAL 				NOT NULL,
	avaliacao			BOOLEAN,
	
CONSTRAINT historico_pk
		PRIMARY KEY (u_id, e_id),
	
	CONSTRAINT historico_fk1
		FOREIGN KEY (u_id) REFERENCES usuario (u_id)
			ON UPDATE CASCADE
			ON DELETE CASCADE,
	
	CONSTRAINT historico_fk2
		FOREIGN KEY (e_id) REFERENCES encontro (e_id)
			ON UPDATE CASCADE
			ON DELETE CASCADE
);

CREATE TABLE encontro_local (
	l_id				SERIAL 				NOT NULL,
	e_id				SERIAL 				NOT NULL,
	
CONSTRAINT encontro_local_pk
		PRIMARY KEY (l_id, e_id),
	
	CONSTRAINT encontro_local_fk1
		FOREIGN KEY (l_id) REFERENCES localidade (l_id)
			ON UPDATE CASCADE
			ON DELETE CASCADE,
	
	CONSTRAINT encontro_local_fk2
		FOREIGN KEY (e_id) REFERENCES encontro (e_id)
			ON UPDATE CASCADE
			ON DELETE CASCADE
);


---------------- FUNÇÕES E TRIGGERS ----------------


--------------- CALCULA IDADE ----------------------
CREATE OR REPLACE FUNCTION calculaIdade()
 RETURNS TRIGGER
 LANGUAGE PLPGSQL
 AS
 $$
 DECLARE 
 var_idade DATE;
 BEGIN
  	var_idade = NEW.data_nascimento;	
	NEW.idade = extract(YEAR from age(current_date, var_idade));
 	RETURN NEW;
 END;
 $$

CREATE TRIGGER calculaIdadeTest
BEFORE INSERT
ON teste
FOR EACH ROW
EXECUTE PROCEDURE calculaIdade();

-------------- CALCULA MÉDIA HISTÓRICO ---------------

CREATE OR REPLACE FUNCTION calculaMediaHistorico()
 RETURNS TRIGGER
 LANGUAGE PLPGSQL
 AS
 $$
 DECLARE 
 var_media double precision;
 BEGIN
 	select avg(avaliacao)
	into var_media
	from historico;
	
	update historico
	set media_avaliacoes = var_media
	where e_id = new.e_id;

	NEW.media_avaliacoes = var_media;
 	RETURN NEW;
 END;
 $$
 
 CREATE TRIGGER calculaMediaHistorico
AFTER INSERT
ON historico
FOR EACH ROW
EXECUTE PROCEDURE calculaMediaHistorico();

-----------------------------------------------------------


