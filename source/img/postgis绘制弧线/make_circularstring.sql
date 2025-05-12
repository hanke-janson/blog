CREATE OR REPLACE FUNCTION make_circularstring(points geometry(Point)[])
RETURNS geometry(CircularString) AS $BODY$
DECLARE
    start_index integer;
    end_index integer;
    srid integer;
BEGIN
    start_index = array_lower(points, 1);
    end_index = array_upper(points, 1);

    -- The start and end points must have the same SRID. Transforming them is not safe, because this function must
    -- return a CIRCULARSTRING with the start and end points exactly matching the input.

    srid = ST_SRID(points[start_index]);
    IF (ST_SRID(points[end_index]) != srid) THEN
        RAISE EXCEPTION 'Start point SRID (%) differs from end point SRID (%) - they must match.',
            ST_AsEWKT(points[start_index]), ST_AsEWKT(points[end_index]);
    END IF;

    -- ... but all the points in-between can be transformed.
    FOR i IN (start_index + 1) .. (end_index - 1)
    LOOP
        points[i] = ST_Transform(points[i], srid);
    END LOOP;

    RETURN ST_GeomFromEWKT(replace(ST_AsEWKT(ST_MakeLine(points)), 'LINESTRING', 'CIRCULARSTRING'));
END
$BODY$ LANGUAGE plpgsql STABLE;