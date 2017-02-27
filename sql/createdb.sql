
CREATE TYPE pgn_result AS ENUM ('1/2-1/2', '0-1', '1-0', '*');

CREATE TABLE pgn_game (
	game_id bigserial primary key,
	white text not null,
	black text not null,
	result pgn_result not null,
	game jsonb not null,
	game_str text not null,
	eco text
);


