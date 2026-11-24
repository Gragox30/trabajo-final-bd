-- ==========================================================
-- 1. CREACIÓN Y SELECCIÓN DE LA BASE DE DATOS (MySQL)
-- ==========================================================
CREATE DATABASE IF NOT EXISTS bd_datatech;
USE bd_datatech;

-- ==========================================================
-- 2. CREACIÓN DE TABLAS (DDL)
-- ==========================================================

-- Tabla ESTUDIANTE
CREATE TABLE estudiante (
    cod_estudiante  CHAR(7)      PRIMARY KEY,
    nombres         VARCHAR(80)  NOT NULL,
    apellidos       VARCHAR(80)  NOT NULL,
    dni             CHAR(8)      NOT NULL UNIQUE,
    correo          VARCHAR(100) NOT NULL UNIQUE,
    telefono        VARCHAR(15),
    fecha_registro  DATE         NOT NULL
);

-- Tabla DOCENTE
CREATE TABLE docente (
    cod_docente     CHAR(7)      PRIMARY KEY,
    nombres         VARCHAR(80)  NOT NULL,
    apellidos       VARCHAR(80)  NOT NULL,
    especialidad    VARCHAR(80)  NOT NULL,
    correo          VARCHAR(100) NOT NULL UNIQUE,
    telefono        VARCHAR(15)
);

-- Tabla CURSO
CREATE TABLE curso (
    cod_curso       CHAR(7)      PRIMARY KEY,
    nombre_curso    VARCHAR(100) NOT NULL,
    creditos        INT          NOT NULL CHECK (creditos > 0),
    horas           INT          NOT NULL CHECK (horas > 0),
    estado          VARCHAR(15)  DEFAULT 'Activo' NOT NULL CHECK (estado IN ('Activo', 'Inactivo')),
    cod_docente     CHAR(7)      NOT NULL,
    CONSTRAINT fk_curso_docente FOREIGN KEY (cod_docente) REFERENCES docente(cod_docente)
);

-- Tabla MATRICULA
CREATE TABLE matricula (
    cod_matricula    CHAR(7)     PRIMARY KEY,
    cod_estudiante   CHAR(7)     NOT NULL,
    cod_curso        CHAR(7)     NOT NULL,
    fecha_matricula  DATE        NOT NULL,
    estado_matricula VARCHAR(15) DEFAULT 'Válido' NOT NULL CHECK (estado_matricula IN ('Válido', 'Retirado', 'Anulado')),
    CONSTRAINT fk_mat_estudiante FOREIGN KEY (cod_estudiante) REFERENCES estudiante(cod_estudiante),
    CONSTRAINT fk_mat_curso      FOREIGN KEY (cod_curso)      REFERENCES curso(cod_curso),
    CONSTRAINT uq_est_curso      UNIQUE (cod_estudiante, cod_curso)
);

-- Tabla EVALUACION
CREATE TABLE evaluacion (
    cod_evaluacion   CHAR(7)      PRIMARY KEY,
    cod_matricula    CHAR(7)      NOT NULL,
    tipo_evaluacion  VARCHAR(40)  NOT NULL,
    nota_obtenida    DECIMAL(4,2) NOT NULL CHECK (nota_obtenida BETWEEN 0 AND 20),
    fecha_evaluacion DATE         NOT NULL,
    CONSTRAINT fk_eval_matricula FOREIGN KEY (cod_matricula) REFERENCES matricula(cod_matricula)
);

-- ==========================================================
-- 3. INSERCIÓN Y ACTUALIZACIÓN DE DATOS (DML)
-- ==========================================================

-- Docentes
INSERT INTO docente VALUES ('DOC0001', 'Carlos Alberto', 'Mendoza Ríos', 'Bases de Datos', 'cmendoza@datatech.edu.pe', '987654321');
INSERT INTO docente VALUES ('DOC0002', 'María Elena', 'Salazar Cruz', 'Desarrollo Web', 'msalazar@datatech.edu.pe', '987654322');

-- Estudiantes
INSERT INTO estudiante VALUES ('EST0001', 'Jorge Luis', 'Cabeza Caceres', '74859612', 'jcabeza@datatech.edu.pe', '912345678', '2026-03-01');
INSERT INTO estudiante VALUES ('EST0002', 'Lucía Fernanda', 'Quispe Vargas', '71234568', 'lquispe@datatech.edu.pe', '923456789', '2026-03-02');
INSERT INTO estudiante VALUES ('EST0003', 'Pedro Miguel', 'Rojas Torres', '76543219', 'projas@datatech.edu.pe', '934567890', '2026-03-03');

-- Cursos
INSERT INTO curso VALUES ('CUR0001', 'Database Foundations Oracle', 4, 64, 'Activo', 'DOC0001');
INSERT INTO curso VALUES ('CUR0002', 'Programación Web Frontend', 3, 48, 'Activo', 'DOC0002');
INSERT INTO curso VALUES ('CUR0003', 'Redes y Conectividad', 3, 48, 'Inactivo', 'DOC0001');

-- Matrículas
INSERT INTO matricula VALUES ('MAT0001', 'EST0001', 'CUR0001', '2026-03-10', 'Válido');
INSERT INTO matricula VALUES ('MAT0002', 'EST0002', 'CUR0001', '2026-03-10', 'Válido');
INSERT INTO matricula VALUES ('MAT0003', 'EST0003', 'CUR0002', '2026-03-11', 'Válido');

-- Evaluaciones
INSERT INTO evaluacion VALUES ('EVA0001', 'MAT0001', 'Examen Final', 18.50, '2026-07-15');
INSERT INTO evaluacion VALUES ('EVA0002', 'MAT0002', 'Examen Final', 11.00, '2026-07-15');
INSERT INTO evaluacion VALUES ('EVA0003', 'MAT0003', 'Examen Final', 15.00, '2026-07-16');

-- Actualización de ejemplo (UPDATE)
UPDATE estudiante SET telefono = '999888777' WHERE cod_estudiante = 'EST0001';

-- ==========================================================
-- 4. CONSULTAS REQUERIDAS (DQL - Adaptadas con CONCAT)
-- ==========================================================

-- 1. Mostrar todos los estudiantes registrados (con ORDER BY)
SELECT cod_estudiante, apellidos, nombres, dni, correo
FROM estudiante
ORDER BY apellidos ASC;

-- 2. Mostrar todos los cursos activos (con WHERE)
SELECT cod_curso, nombre_curso, creditos, horas
FROM curso
WHERE estado = 'Activo';

-- 3. Listar las matrículas realizadas
SELECT cod_matricula, cod_estudiante, cod_curso, fecha_matricula, estado_matricula
FROM matricula;

-- 4. Mostrar cursos con sus docentes asignados (INNER JOIN)
SELECT c.cod_curso, c.nombre_curso, CONCAT(d.nombres, ' ', d.apellidos) AS docente_asignado, d.especialidad
FROM curso c
INNER JOIN docente d ON c.cod_docente = d.cod_docente;

-- 5. Mostrar estudiantes con sus respectivos cursos (3 tablas relacionadas)
SELECT e.cod_estudiante, CONCAT(e.nombres, ' ', e.apellidos) AS estudiante, c.nombre_curso, m.estado_matricula
FROM estudiante e
INNER JOIN matricula m ON e.cod_estudiante = m.cod_estudiante
INNER JOIN curso c ON m.cod_curso = c.cod_curso
ORDER BY c.nombre_curso, e.apellidos;

-- 6. Mostrar notas de estudiantes por curso e identificar aprobados/desaprobados (4 tablas relacionadas)
SELECT CONCAT(e.nombres, ' ', e.apellidos) AS estudiante,
       c.nombre_curso,
       ev.tipo_evaluacion,
       ev.nota_obtenida,
       CASE WHEN ev.nota_obtenida >= 13 THEN 'APROBADO' ELSE 'DESAPROBADO' END AS condicion
FROM estudiante e
INNER JOIN matricula m ON e.cod_estudiante = m.cod_estudiante
INNER JOIN curso c ON m.cod_curso = c.cod_curso
INNER JOIN evaluacion ev ON m.cod_matricula = ev.cod_matricula
ORDER BY ev.nota_obtenida DESC;

-- 7. Cursos con mayor cantidad de matrículas
SELECT c.nombre_curso, COUNT(m.cod_matricula) AS total_matriculados
FROM curso c
LEFT JOIN matricula m ON c.cod_curso = m.cod_curso
GROUP BY c.nombre_curso
ORDER BY total_matriculados DESC;