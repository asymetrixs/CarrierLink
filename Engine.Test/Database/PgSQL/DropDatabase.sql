-- TERMINATE EXISTING CONNETIONS
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'voiptest';

-- DROP DATABASE
DROP DATABASE voiptest;