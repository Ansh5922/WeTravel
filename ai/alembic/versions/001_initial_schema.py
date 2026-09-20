"""Initial schema revision with vector extension and core tables

Revision ID: 001_initial_schema
Revises: 
Create Date: 2026-09-21 00:00:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
from pgvector.sqlalchemy import Vector

revision: str = '001_initial_schema'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

def upgrade() -> None:
    op.execute("CREATE EXTENSION IF NOT EXISTS vector;")

    op.create_table(
        'users',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), primary_key=True),
        sa.Column('email', sa.String(length=255), nullable=False, unique=True),
        sa.Column('password_hash', sa.String(length=255), nullable=True),
        sa.Column('full_name', sa.String(length=100), nullable=True),
        sa.Column('phone', sa.String(length=20), nullable=True),
        sa.Column('is_premium', sa.Boolean(), server_default=sa.text('false'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('CURRENT_TIMESTAMP'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('CURRENT_TIMESTAMP'), nullable=False),
    )

    op.create_table(
        'user_profiles',
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), primary_key=True),
        sa.Column('dietary_preference', sa.String(length=50), nullable=True),
        sa.Column('travel_style', sa.String(length=50), nullable=True),
        sa.Column('budget_tier', sa.String(length=30), nullable=True),
        sa.Column('pace_preference', sa.String(length=30), nullable=True),
        sa.Column('health_constraints', postgresql.JSONB(), nullable=True),
        sa.Column('climate_sensitivities', postgresql.JSONB(), nullable=True),
        sa.Column('raw_preference_notes', sa.Text(), nullable=True),
        sa.Column('preference_vector', Vector(384), nullable=True),
    )

    op.create_table(
        'trip_groups',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), primary_key=True),
        sa.Column('name', sa.String(length=150), nullable=False),
        sa.Column('cover_image_url', sa.Text(), nullable=True),
        sa.Column('created_by', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('status', sa.String(length=30), server_default='planning', nullable=False),
        sa.Column('trip_start_date', sa.Date(), nullable=True),
        sa.Column('trip_end_date', sa.Date(), nullable=True),
        sa.Column('chat_retention_deadline', sa.Date(), nullable=True),
        sa.Column('preserve_chat', sa.Boolean(), server_default=sa.text('false'), nullable=False),
    )

    op.create_table(
        'group_consensus_profiles',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), primary_key=True),
        sa.Column('group_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('trip_groups.id', ondelete='CASCADE'), unique=True, nullable=False),
        sa.Column('computed_budget_range', postgresql.JSONB(), nullable=True),
        sa.Column('hard_constraints', postgresql.JSONB(), nullable=True),
        sa.Column('consensus_vector', Vector(384), nullable=True),
        sa.Column('last_edited_by', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id'), nullable=True),
        sa.Column('is_locked_by_admin', sa.Boolean(), server_default=sa.text('false'), nullable=False),
    )

    op.create_table(
        'polls',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), primary_key=True),
        sa.Column('group_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('trip_groups.id', ondelete='CASCADE'), nullable=False),
        sa.Column('created_by', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('question', sa.Text(), nullable=False),
        sa.Column('status', sa.String(length=20), server_default='open', nullable=False),
        sa.Column('poll_vector', Vector(384), nullable=True),
    )

    op.create_table(
        'interaction_embeddings',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), primary_key=True),
        sa.Column('group_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('trip_groups.id', ondelete='CASCADE'), nullable=False),
        sa.Column('source_type', sa.String(length=50), nullable=False),
        sa.Column('source_id', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('summary_text', sa.Text(), nullable=False),
        sa.Column('context_vector', Vector(384), nullable=True),
    )

    op.create_table(
        'destinations_catalog',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), primary_key=True),
        sa.Column('name', sa.String(length=150), nullable=False),
        sa.Column('state', sa.String(length=100), nullable=True),
        sa.Column('country', sa.String(length=100), nullable=True),
        sa.Column('tags', postgresql.JSONB(), nullable=True),
        sa.Column('climate_type', sa.String(length=50), nullable=True),
        sa.Column('avg_daily_cost', sa.Numeric(precision=10, scale=2), nullable=True),
        sa.Column('destination_vector', Vector(384), nullable=True),
    )

def downgrade() -> None:
    op.drop_table('destinations_catalog')
    op.drop_table('interaction_embeddings')
    op.drop_table('polls')
    op.drop_table('group_consensus_profiles')
    op.drop_table('trip_groups')
    op.drop_table('user_profiles')
    op.drop_table('users')
