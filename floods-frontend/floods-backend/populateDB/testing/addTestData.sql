begin;

-- Add communities
insert into floods.community (id, name, abbreviation, viewportgeojson) values
  (1, 'All of Savannah', 'AOS', ST_AsGeoJSON(ST_MakeEnvelope(-81.088371, 32.076176, -81.088371, 32.076176))),
  (2, 'Downtown', 'DNT', ST_AsGeoJSON(ST_MakeEnvelope(-81.088371, 32.076176, -81.088371, 32.076176)));
alter sequence floods.community_id_seq restart with 3;

-- Set the jwt claim settings so the register user function works
-- Make sure they're local so we actually use the token outside of this script
select set_config('jwt.claims.community_id', '1', true);
select set_config('jwt.claims.role', 'floods_super_admin', true);
-- Add users
alter sequence floods.user_id_seq restart with 1;
select floods.register_user(text 'Super', text 'Admin', text 'Superhero, Administrator', integer '1', text '867-5309', text 'superadmin@flo.ods', text 'texasfloods', text 'floods_super_admin');
alter sequence floods.user_id_seq restart with 2;
select floods.register_user(text 'Community', text 'Admin', text 'Community Administrator', integer '1', text '867-5309', text 'admin@community.floods', text 'texasfloods', text 'floods_community_admin');
alter sequence floods.user_id_seq restart with 3;
select floods.register_user(text 'Community', text 'Editor', text 'Community Editor', integer '1', text '867-5309', text 'editor@community.floods', text 'texasfloods', text 'floods_community_editor');
alter sequence floods.user_id_seq restart with 4;
select floods.register_user(text 'Other Community', text 'Admin', text 'Community Administrator', integer '2', text '867-5309', text 'admin@othercommunity.floods', text 'texasfloods', text 'floods_community_admin');
alter sequence floods.user_id_seq restart with 5;
select floods.register_user(text 'Community', text 'Editor Too', text 'Community Editor Too', integer '1', text '867-5309', text 'editortoo@community.floods', text 'texasfloods', text 'floods_community_editor');
alter sequence floods.user_id_seq restart with 6;
select floods.register_user(text 'Inactive', text 'User', text 'Retired', integer '1', text '867-5309', text 'inactive@flo.ods', text 'texasfloods', text 'floods_community_editor');
alter sequence floods.user_id_seq restart with 7;
select floods.register_user(text 'Floods', text 'Graphql', text 'API', integer '1', text '000-0000', text 'graphql@flo.ods', text 'floods_graphql', text 'floods_super_admin', boolean 'true');

-- Add crossings
insert into floods.crossing (id, name, human_address, description, coordinates, geojson, community_ids) values
  (1, 'Downtown Savannah', 'Habersham & Ogelthorpe · Savannah, GA 31401', 'Habersham & Ogelthorpe', ST_MakePoint(-81.088371, 32.076176), ST_AsGeoJSON(ST_MakePoint(-81.088371, 32.076176)), '{1}'),
  (2, 'Forsyth', 'at the park', 'Crossing at the park', ST_MakePoint(-81.095875, 32.067270), ST_AsGeoJSON(ST_MakePoint(-81.095875, 32.067270)), '{1}'),
  (3, 'Library', 'at the library', 'Crossing at the library', ST_MakePoint(-81.099302, 32.057910), ST_AsGeoJSON(ST_MakePoint(-81.099302, 32.057910)), '{1}'),
  (4, 'City Hall', 'at city hall', 'Crossing at city hall', ST_MakePoint(-81.090937, 32.081003), ST_AsGeoJSON(ST_MakePoint(-81.090937, 32.081003)), '{1}'),
  (5, 'River Street', 'on river street', 'Crossing on river street', ST_MakePoint(-81.086685, 32.080239), ST_AsGeoJSON(ST_MakePoint(-81.086685, 32.080239)), '{1}'),
  (6, 'Coffee Shop', 'at the coffee shop', 'Crossing at the coffee shop', ST_MakePoint(-81.091833, 32.078676), ST_AsGeoJSON(ST_MakePoint(-81.091833, 32.078676)), '{1}'),
  (7, 'other community', 'in the other community', 'Crossing in the other community', ST_MakePoint(-81.082567, 32.073076), ST_AsGeoJSON(ST_MakePoint(-81.082567, 32.073076)), '{1,2}'),
  (8, 'other community 2', 'another in the other community', 'Another crossing in the other community', ST_MakePoint(-81.104959, 32.062638), ST_AsGeoJSON(ST_MakePoint(-81.104959, 32.062638)), '{2}');
alter sequence floods.crossing_id_seq restart with 9;

-- Update community viewports based on crossings
update floods.community
  set viewportgeojson = (select ST_AsGeoJSON(ST_Envelope(ST_Extent(c.coordinates))) from floods.crossing c where array_position(c.community_ids, 1) >= 0)
  where id = 1;
update floods.community
  set viewportgeojson = (select ST_AsGeoJSON(ST_Envelope(ST_Extent(c.coordinates))) from floods.crossing c where array_position(c.community_ids, 2) >= 0)
  where id = 2;

-- Add statuses
insert into floods.status (id, name) values
  (1, 'Open'),
  (2, 'Closed'),
  (3, 'Caution'),
  (4, 'Long-Term Closure');
alter sequence floods.status_id_seq restart with 5;

-- Add status reasons
insert into floods.status_reason (id, status_id, name) values
  (1, 2, 'Flooded'),
  (2, 4, 'Bridge Broken'),
  (3, 3, 'Unconfirmed Flooding');
alter sequence floods.status_reason_id_seq restart with 4;

-- Add status associations
insert into floods.status_association (id, status_id, detail, rule) values
  (1, 1, 'reason', 'disabled'),
  (2, 1, 'duration', 'disabled'),
  (3, 2, 'reason', 'required'),
  (4, 2, 'duration', 'disabled'),
  (5, 3, 'reason', 'required'),
  (6, 3, 'duration', 'disabled'),
  (7, 4, 'reason', 'required'),
  (8, 4, 'duration', 'required');
alter sequence floods.status_association_id_seq restart with 9;

-- Add status updates
insert into floods.status_update (id, status_id, creator_id, crossing_id, notes, status_reason_id, created_at) values
   (1, 1, 1, 1, 'notes', null, '2019-05-03T09:27:57Z'),
   (2, 2, 1, 1, 'notes', 1, '2019-05-04T09:27:57Z'),
   (3, 1, 1, 2, 'notes', null, '2019-05-06T09:27:57Z'),
   (4, 1, 1, 3, 'notes', null, '2019-05-08T09:27:57Z'),
   (5, 1, 1, 5, 'notes', null, '2019-05-11T09:27:57Z'),
   (6, 2, 1, 2, 'notes', 1, '2019-05-09T09:27:57Z'),
   (7, 1, 1, 1, 'notes', null, '2019-05-09T09:27:57Z'),
   (8, 2, 1, 3, 'notes', 1, '2019-05-12T09:27:57Z'),
   (9, 1, 1, 4, 'notes', null, '2019-05-14T09:27:57Z'),
  (10, 2, 1, 1, 'notes', 1, '2019-05-12T09:27:57Z'),
  (11, 2, 1, 5, 'notes', 1, '2019-05-17T09:27:57Z'),
  (12, 1, 1, 6, 'notes', null, '2019-05-19T09:27:57Z'),
  (13, 1, 1, 5, 'notes', null, '2019-05-19T09:27:57Z'),
  (14, 1, 1, 5, 'notes', null, '2019-05-20T09:27:57Z'),
  (15, 1, 1, 4, 'notes', null, '2019-05-20T09:27:57Z'),
  (16, 1, 1, 3, 'notes', null, '2019-05-20T09:27:57Z'),
  (17, 1, 1, 1, 'notes', null, '2019-05-19T09:27:57Z'),
  (18, 1, 1, 4, 'notes', null, '2019-05-23T09:27:57Z'),
  (19, 2, 1, 5, 'notes', 1, '2019-05-25T09:27:57Z'),
  (20, 2, 1, 3, 'notes', 1, '2019-05-24T09:27:57Z'),
  (21, 1, 1, 2, 'notes', null, '2019-05-24T09:27:57Z'),
  (22, 1, 1, 5, 'notes', null, '2019-05-28T09:27:57Z'),
  (23, 2, 1, 1, 'notes', 1, '2019-05-25T09:27:57Z'),
  (24, 2, 1, 6, 'notes', 1, '2019-05-31T09:27:57Z'),
  (25, 1, 1, 1, 'notes', null, '2019-05-27T09:27:57Z'),
  (26, 2, 1, 1, 'notes', 1, '2019-05-28T09:27:57Z'),
  (27, 2, 1, 2, 'notes', 1, '2019-05-30T09:27:57Z'),
  (28, 1, 1, 3, 'notes', null, '2019-06-01T09:27:57Z'),
  (29, 2, 1, 5, 'notes', 1, '2019-06-04T09:27:57Z'),
  (30, 1, 1, 2, 'notes', null, '2019-06-02T09:27:57Z'),
  (31, 1, 4, 7, 'notes', null, '2019-06-02T09:27:57Z'),
  (32, 1, 4, 8, 'notes', null, '2019-06-02T09:27:57Z');
alter sequence floods.status_update_id_seq restart with 33;

-- Add latest status updates
update floods.crossing set latest_status_update_id = 26 where id = 1;
update floods.crossing set latest_status_update_id = 30 where id = 2;
update floods.crossing set latest_status_update_id = 28 where id = 3;
update floods.crossing set latest_status_update_id = 18 where id = 4;
update floods.crossing set latest_status_update_id = 29 where id = 5;
update floods.crossing set latest_status_update_id = 24 where id = 6;
update floods.crossing set latest_status_update_id = 31 where id = 7;
update floods.crossing set latest_status_update_id = 32 where id = 8;

-- Add latest statuses
update floods.crossing set latest_status_id = 2 where id = 1;
update floods.crossing set latest_status_id = 1 where id = 2;
update floods.crossing set latest_status_id = 1 where id = 3;
update floods.crossing set latest_status_id = 1 where id = 4;
update floods.crossing set latest_status_id = 2 where id = 5;
update floods.crossing set latest_status_id = 2 where id = 6;
update floods.crossing set latest_status_id = 1 where id = 7;
update floods.crossing set latest_status_id = 1 where id = 8;

-- Add latest status times
update floods.crossing set latest_status_created_at = '2019-05-28T09:27:57Z' where id = 1;
update floods.crossing set latest_status_created_at = '2019-06-02T09:27:57Z' where id = 2;
update floods.crossing set latest_status_created_at = '2019-06-01T09:27:57Z' where id = 3;
update floods.crossing set latest_status_created_at = '2019-05-23T09:27:57Z' where id = 4;
update floods.crossing set latest_status_created_at = '2019-06-04T09:27:57Z' where id = 5;
update floods.crossing set latest_status_created_at = '2019-05-31T09:27:57Z' where id = 6;
update floods.crossing set latest_status_created_at = '2019-06-02T09:27:57Z' where id = 7;
update floods.crossing set latest_status_created_at = '2019-06-02T09:27:57Z' where id = 8;

commit;
begin;

-- Add communities
insert into floods.community (id, name, abbreviation, viewportgeojson) values
  (1, 'All of Savannah', 'AOS', ST_AsGeoJSON(ST_MakeEnvelope(-81.088371, 32.076176, -81.088371, 32.076176))),
  (2, 'Downtown', 'DNT', ST_AsGeoJSON(ST_MakeEnvelope(-81.088371, 32.076176, -81.088371, 32.076176)));
alter sequence floods.community_id_seq restart with 3;

-- Set the jwt claim settings so the register user function works
-- Make sure they're local so we actually use the token outside of this script
select set_config('jwt.claims.community_id', '1', true);
select set_config('jwt.claims.role', 'floods_super_admin', true);
-- Add users
alter sequence floods.user_id_seq restart with 1;
select floods.register_user(text 'Super', text 'Admin', text 'Superhero, Administrator', integer '1', text '867-5309', text 'superadmin@flo.ods', text 'texasfloods', text 'floods_super_admin');
alter sequence floods.user_id_seq restart with 2;
select floods.register_user(text 'Community', text 'Admin', text 'Community Administrator', integer '1', text '867-5309', text 'admin@community.floods', text 'texasfloods', text 'floods_community_admin');
alter sequence floods.user_id_seq restart with 3;
select floods.register_user(text 'Community', text 'Editor', text 'Community Editor', integer '1', text '867-5309', text 'editor@community.floods', text 'texasfloods', text 'floods_community_editor');
alter sequence floods.user_id_seq restart with 4;
select floods.register_user(text 'Other Community', text 'Admin', text 'Community Administrator', integer '2', text '867-5309', text 'admin@othercommunity.floods', text 'texasfloods', text 'floods_community_admin');
alter sequence floods.user_id_seq restart with 5;
select floods.register_user(text 'Community', text 'Editor Too', text 'Community Editor Too', integer '1', text '867-5309', text 'editortoo@community.floods', text 'texasfloods', text 'floods_community_editor');
alter sequence floods.user_id_seq restart with 6;
select floods.register_user(text 'Inactive', text 'User', text 'Retired', integer '1', text '867-5309', text 'inactive@flo.ods', text 'texasfloods', text 'floods_community_editor');
alter sequence floods.user_id_seq restart with 7;
select floods.register_user(text 'Floods', text 'Graphql', text 'API', integer '1', text '000-0000', text 'graphql@flo.ods', text 'floods_graphql', text 'floods_super_admin', boolean 'true');

-- Add crossings
insert into floods.crossing (id, name, human_address, description, coordinates, geojson, community_ids) values
  (1, 'Downtown Savannah', 'Habersham & Ogelthorpe · Savannah, GA 31401', 'Habersham & Ogelthorpe', ST_MakePoint(-81.088371, 32.076176), ST_AsGeoJSON(ST_MakePoint(-81.088371, 32.076176)), '{1}'),
  (2, 'Forsyth', 'at the park', 'Crossing at the park', ST_MakePoint(-81.095875, 32.067270), ST_AsGeoJSON(ST_MakePoint(-81.095875, 32.067270)), '{1}'),
  (3, 'Library', 'at the library', 'Crossing at the library', ST_MakePoint(-81.099302, 32.057910), ST_AsGeoJSON(ST_MakePoint(-81.099302, 32.057910)), '{1}'),
  (4, 'City Hall', 'at city hall', 'Crossing at city hall', ST_MakePoint(-81.090937, 32.081003), ST_AsGeoJSON(ST_MakePoint(-81.090937, 32.081003)), '{1}'),
  (5, 'River Street', 'on river street', 'Crossing on river street', ST_MakePoint(-81.086685, 32.080239), ST_AsGeoJSON(ST_MakePoint(-81.086685, 32.080239)), '{1}'),
  (6, 'Coffee Shop', 'at the coffee shop', 'Crossing at the coffee shop', ST_MakePoint(-81.091833, 32.078676), ST_AsGeoJSON(ST_MakePoint(-81.091833, 32.078676)), '{1}'),
  (7, 'other community', 'in the other community', 'Crossing in the other community', ST_MakePoint(-81.082567, 32.073076), ST_AsGeoJSON(ST_MakePoint(-81.082567, 32.073076)), '{1,2}'),
  (8, 'other community 2', 'another in the other community', 'Another crossing in the other community', ST_MakePoint(-81.104959, 32.062638), ST_AsGeoJSON(ST_MakePoint(-81.104959, 32.062638)), '{2}');
alter sequence floods.crossing_id_seq restart with 9;

-- Update community viewports based on crossings
update floods.community
  set viewportgeojson = (select ST_AsGeoJSON(ST_Envelope(ST_Extent(c.coordinates))) from floods.crossing c where array_position(c.community_ids, 1) >= 0)
  where id = 1;
update floods.community
  set viewportgeojson = (select ST_AsGeoJSON(ST_Envelope(ST_Extent(c.coordinates))) from floods.crossing c where array_position(c.community_ids, 2) >= 0)
  where id = 2;

-- Add statuses
insert into floods.status (id, name) values
  (1, 'Open'),
  (2, 'Closed'),
  (3, 'Caution'),
  (4, 'Long-Term Closure');
alter sequence floods.status_id_seq restart with 5;

-- Add status reasons
insert into floods.status_reason (id, status_id, name) values
  (1, 2, 'Flooded'),
  (2, 4, 'Bridge Broken'),
  (3, 3, 'Unconfirmed Flooding');
alter sequence floods.status_reason_id_seq restart with 4;

-- Add status associations
insert into floods.status_association (id, status_id, detail, rule) values
  (1, 1, 'reason', 'disabled'),
  (2, 1, 'duration', 'disabled'),
  (3, 2, 'reason', 'required'),
  (4, 2, 'duration', 'disabled'),
  (5, 3, 'reason', 'required'),
  (6, 3, 'duration', 'disabled'),
  (7, 4, 'reason', 'required'),
  (8, 4, 'duration', 'required');
alter sequence floods.status_association_id_seq restart with 9;

-- Add status updates
insert into floods.status_update (id, status_id, creator_id, crossing_id, notes, status_reason_id, created_at) values
   (1, 1, 1, 1, 'notes', null, '2019-05-03T09:27:57Z'),
   (2, 2, 1, 1, 'notes', 1, '2019-05-04T09:27:57Z'),
   (3, 1, 1, 2, 'notes', null, '2019-05-06T09:27:57Z'),
   (4, 1, 1, 3, 'notes', null, '2019-05-08T09:27:57Z'),
   (5, 1, 1, 5, 'notes', null, '2019-05-11T09:27:57Z'),
   (6, 2, 1, 2, 'notes', 1, '2019-05-09T09:27:57Z'),
   (7, 1, 1, 1, 'notes', null, '2019-05-09T09:27:57Z'),
   (8, 2, 1, 3, 'notes', 1, '2019-05-12T09:27:57Z'),
   (9, 1, 1, 4, 'notes', null, '2019-05-14T09:27:57Z'),
  (10, 2, 1, 1, 'notes', 1, '2019-05-12T09:27:57Z'),
  (11, 2, 1, 5, 'notes', 1, '2019-05-17T09:27:57Z'),
  (12, 1, 1, 6, 'notes', null, '2019-05-19T09:27:57Z'),
  (13, 1, 1, 5, 'notes', null, '2019-05-19T09:27:57Z'),
  (14, 1, 1, 5, 'notes', null, '2019-05-20T09:27:57Z'),
  (15, 1, 1, 4, 'notes', null, '2019-05-20T09:27:57Z'),
  (16, 1, 1, 3, 'notes', null, '2019-05-20T09:27:57Z'),
  (17, 1, 1, 1, 'notes', null, '2019-05-19T09:27:57Z'),
  (18, 1, 1, 4, 'notes', null, '2019-05-23T09:27:57Z'),
  (19, 2, 1, 5, 'notes', 1, '2019-05-25T09:27:57Z'),
  (20, 2, 1, 3, 'notes', 1, '2019-05-24T09:27:57Z'),
  (21, 1, 1, 2, 'notes', null, '2019-05-24T09:27:57Z'),
  (22, 1, 1, 5, 'notes', null, '2019-05-28T09:27:57Z'),
  (23, 2, 1, 1, 'notes', 1, '2019-05-25T09:27:57Z'),
  (24, 2, 1, 6, 'notes', 1, '2019-05-31T09:27:57Z'),
  (25, 1, 1, 1, 'notes', null, '2019-05-27T09:27:57Z'),
  (26, 2, 1, 1, 'notes', 1, '2019-05-28T09:27:57Z'),
  (27, 2, 1, 2, 'notes', 1, '2019-05-30T09:27:57Z'),
  (28, 1, 1, 3, 'notes', null, '2019-06-01T09:27:57Z'),
  (29, 2, 1, 5, 'notes', 1, '2019-06-04T09:27:57Z'),
  (30, 1, 1, 2, 'notes', null, '2019-06-02T09:27:57Z'),
  (31, 1, 4, 7, 'notes', null, '2019-06-02T09:27:57Z'),
  (32, 1, 4, 8, 'notes', null, '2019-06-02T09:27:57Z');
alter sequence floods.status_update_id_seq restart with 33;

-- Add latest status updates
update floods.crossing set latest_status_update_id = 26 where id = 1;
update floods.crossing set latest_status_update_id = 30 where id = 2;
update floods.crossing set latest_status_update_id = 28 where id = 3;
update floods.crossing set latest_status_update_id = 18 where id = 4;
update floods.crossing set latest_status_update_id = 29 where id = 5;
update floods.crossing set latest_status_update_id = 24 where id = 6;
update floods.crossing set latest_status_update_id = 31 where id = 7;
update floods.crossing set latest_status_update_id = 32 where id = 8;

-- Add latest statuses
update floods.crossing set latest_status_id = 2 where id = 1;
update floods.crossing set latest_status_id = 1 where id = 2;
update floods.crossing set latest_status_id = 1 where id = 3;
update floods.crossing set latest_status_id = 1 where id = 4;
update floods.crossing set latest_status_id = 2 where id = 5;
update floods.crossing set latest_status_id = 2 where id = 6;
update floods.crossing set latest_status_id = 1 where id = 7;
update floods.crossing set latest_status_id = 1 where id = 8;

-- Add latest status times
update floods.crossing set latest_status_created_at = '2019-05-28T09:27:57Z' where id = 1;
update floods.crossing set latest_status_created_at = '2019-06-02T09:27:57Z' where id = 2;
update floods.crossing set latest_status_created_at = '2019-06-01T09:27:57Z' where id = 3;
update floods.crossing set latest_status_created_at = '2019-05-23T09:27:57Z' where id = 4;
update floods.crossing set latest_status_created_at = '2019-06-04T09:27:57Z' where id = 5;
update floods.crossing set latest_status_created_at = '2019-05-31T09:27:57Z' where id = 6;
update floods.crossing set latest_status_created_at = '2019-06-02T09:27:57Z' where id = 7;
update floods.crossing set latest_status_created_at = '2019-06-02T09:27:57Z' where id = 8;

commit;
