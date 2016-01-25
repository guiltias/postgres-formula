{% set postgres = salt['pillar.get']('postgres', default=lookup, merge=True) %}

/etc/wal-e.d/{{ postgres.dbalias }}/env:
  file.directory:
    - user: root
    - group: postgrs
    - mode: 711
    - makedirs: True

/etc/wal-e.d/{{ postgres.dbalias }}/env/AWS_ACCESS_KEY_ID:
  file.managed:
    - contents:
      - {{ postgres.aws.access_key_id }}

/etc/wal-e.d/{{ postgres.dbalias }}/env/AWS_SECRET_ACCESS_KEY:
  file.managed:
    - contents:
      - {{ postgres.aws.secret_access_key }}

/etc/wal-e.d/{{ postgres.dbalias }}/env/WALE_S3_PREFIX:
  file.managed:
    - contents:
      - {{ postgres.aws.wale_s3_prefix }}
