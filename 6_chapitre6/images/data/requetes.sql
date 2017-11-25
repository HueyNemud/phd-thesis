
--EXTREMITIES
DROP table verniquet_nodes;
DROP table verniquet_extremities;
CREATE  TABLE verniquet_nodes AS SELECT gid,nom_entier,st_closestpoint(the_geom,st_centroid(the_geom))as the_geom from rues_verniquet;
CREATE TABLE verniquet_extremities AS SELECT st_endpoint(the_geom)as the_geom from rues_verniquet;
INSERT INTO verniquet_extremities (the_geom) SELECT st_startpoint(the_geom)as the_geom from rues_verniquet;

SELECT gid, type_voie as nature, particule||' '||nom_voie as nom, nom_entier, '(1783,1785,1791,1799)'::text as vtime,st_astext(the_geom) as the_geom from rues_verniquet WHERE st_distance(st_setsrid(st_makepoint(652251, 6861876),2154), the_geom) < 20;


--VERITES TERRAIN
SELECT hot_createGFViz('truth_stmartin',1);


--CREATION DU GRAPHE (GRENETA)
SELECT hot_createGFViz('verniquet_greneta',1);
DROP TABLE graph_serie_nodes_verniquet_greneta;
DROP TABLE graph_serie_edges_verniquet_greneta;
SELECT hot_createGraphSerieViz('verniquet_greneta', 200,20,'nom_entier');
SELECT hot_getobservationattribute(1888,2,'nom_entier');

--CREATION DU GRAPHE (ST MARTIN)
SELECT hot_createGFViz('stmartin',1);
DROP TABLE graph_serie_nodes_stmartin;
DROP TABLE graph_serie_edges_stmartin;
SELECT hot_createGraphSerieViz('stmartin', 400,20,'nom_entier');


--Comparaison entre ALGOS
--Donne les liens qui sont dans la vérité terrain (vrais positifs) pour MUSTIERE
SELECT count(*) FROM mustiere as m JOIN (SELECT tail_gid ,head_gid FROM gf WHERE run LIKE 'truth_stmartin' AND tail_snap_id=2 AND head_snap_id=3) t ON m.tail_gid=t.tail_gid AND m.head_gid=t.head_gid ;
--Donne tous les liens la verite terrain
SELECT count(*) from gf where run LIKE 'truth_stmartin' AND tail_snap_id = 2 AND head_snap_id=3;
--Donne tous les liens de MUSTIERE
SELECT count(*) from mustiere;

--Ce qu'on a trouvé nous
SELECT count(*) from gf where run LIKE 'stmartin2' AND tail_snap_id = 2 AND head_snap_id=3;
--Tous nos liens qui sont dans la vérité terrain
SELECT count(*) from gf  JOIN (SELECT tail_gid ,head_gid FROM gf WHERE run LIKE 'truth_stmartin')  t ON gf.tail_gid=t.tail_gid AND gf.head_gid=t.head_gid  where run LIKE 'stmartin2' AND tail_snap_id = 1 AND head_snap_id=2




CREATE OR REPLACE FUNCTION public.hot_creategraphserieviz(graph_name character varying, col_width double precision, y_gap double precision, attribute_name character varying)
  RETURNS void AS
$BODY$
DECLARE
	r gf_view_verniquet_greneta%rowtype;
	nodes_table_name varchar;
	edges_table_name varchar;
	y float;
	i integer;
	element_name varchar;
	tail_point text;
	head_point text;
	test integer;
BEGIN

		-- CREATE THE NODES
		EXECUTE 'DROP TABLE IF EXISTS graph_serie_nodes_'||graph_name||'';
		EXECUTE 'CREATE TABLE graph_serie_nodes_'||graph_name||' ( id integer, snap_id integer, att_name varchar, the_geom geometry)';
		nodes_table_name:= 'graph_serie_nodes_'||graph_name;
		i := 1;
		DROP TABLE IF EXISTS tmp;
		EXECUTE format('CREATE TEMPORARY TABLE tmp AS SELECT * , st_x(st_centroid(st_startpoint(geom))) as xc FROM  gf_view_%s ORDER BY xc asc',graph_name);
 		FOR r IN SELECT * FROM tmp
		LOOP
			test := 0;
			EXECUTE format('SELECT count(*) FROM %s a WHERE a.snap_id  = %s AND a.id = %s',nodes_table_name,r.tail_snap_id,r.tail_gid) INTO test;
			IF test =0 THEN
				EXECUTE format ('SELECT hot_getobservationattribute(%s,%s,''%s'')', r.tail_gid, r.tail_snap_id,attribute_name) INTO element_name;
				y:= i*y_gap;
				IF element_name IS NULL THEN
					element_name:='';
				END IF;
				--RAISE INFO USING MESSAGE = format ('SELECT hot_getobservationattribute(%s,%s,''%s'')', r.tail_gid, r.tail_snap_id,attribute_name);
				EXECUTE 'INSERT INTO '|| nodes_table_name||' (id, snap_id, att_name, the_geom) VALUES('||r.tail_gid||','||r.tail_snap_id||','''||element_name||''', st_makePoint('||(r.tail_snap_id-1)*col_width ||','|| y||'))';
			END IF;
			i := i+1;
		END LOOP;
		i := 1;
		DROP TABLE tmp;
		EXECUTE format('CREATE TEMPORARY TABLE tmp AS SELECT * , st_x(st_centroid(st_endpoint(geom))) as xc FROM  gf_view_%s ORDER BY xc asc',graph_name);
		FOR r IN SELECT * FROM tmp
		LOOP
			test := 0;
			EXECUTE format('SELECT count(*) FROM %s a WHERE a.snap_id  = %s AND a.id = %s',nodes_table_name,r.head_snap_id,r.head_gid) INTO test;
			IF test = 0 THEN
				EXECUTE format ('SELECT hot_getobservationattribute(%s,%s,''%s'')', r.head_gid, r.head_snap_id,attribute_name) INTO element_name;
				IF element_name IS NULL THEN
					element_name:='';
				END IF;
				--RAISE INFO USING MESSAGE = 'nom (head)= '||element_name;
				EXECUTE 'INSERT INTO '|| nodes_table_name||' (id, snap_id,att_name, the_geom) VALUES('||r.head_gid||','||r.head_snap_id||','''||element_name||''', st_makePoint('||(r.head_snap_id-1)*col_width ||','|| y||'))';
			END IF;
			y:= i*y_gap;
			i := i+1;
		END LOOP;
		-- CREATE THE EDGES
		edges_table_name:= 'graph_serie_edges_'||graph_name;
		EXECUTE 'DROP TABLE IF EXISTS '||edges_table_name;
		EXECUTE 'CREATE TABLE '||edges_table_name||' ( fil_id integer, type varchar, belief double precision, tail_gid integer, tail_snap_id integer, head_gid integer, head_snap_id integer, the_geom geometry)';

		DROP TABLE tmp;
		EXECUTE format('CREATE TEMPORARY TABLE tmp AS SELECT * FROM gf_view_%s',graph_name);
		FOR r IN SELECT * FROM tmp LOOP
			--RAISE INFO USING MESSAGE = 'DEBUJE = SELECT st_astext(the_geom) FROM '||nodes_table_name||' WHERE id = '||r.tail_gid ||' AND snap_id='|| r.tail_snap_id||'';
			EXECUTE 'SELECT st_astext(the_geom) FROM '||nodes_table_name||' WHERE id = '||r.tail_gid ||' AND snap_id='|| r.tail_snap_id||'' INTO tail_point;
			--RAISE INFO USING MESSAGE = 'DEBUJE 2 =SELECT st_astext(the_geom) FROM '||nodes_table_name||' WHERE id= '||r.head_gid||' AND snap_id='|| r.head_snap_id||'';
			EXECUTE 'SELECT st_astext(the_geom) FROM '||nodes_table_name||' WHERE id= '||r.head_gid||' AND snap_id='|| r.head_snap_id||'' INTO head_point;
			--RAISE INFO USING MESSAGE = 'tail : '||tail_point;
			RAISE INFO USING MESSAGE = graph_name||' FROM '||r.tail_gid||' TO '||r.head_gid;
			EXECUTE format('INSERT INTO %s (fil_id, type, belief, tail_gid, tail_snap_id, head_gid,head_snap_id, the_geom) VALUES ('||r.filiation_id||','''||r.type||''','||r.belief||','||r.tail_gid||','||r.tail_snap_id||','||r.head_gid||','||r.head_snap_id||',st_MakeLine(st_geomfromtext('''||tail_point||'''),st_geomfromtext('''||head_point||''')))',edges_table_name);
		END LOOP;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.hot_creategraphserieviz(character varying, double precision, double precision, character varying)
  OWNER TO bdumenieu;


