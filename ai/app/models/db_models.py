import uuid
from sqlalchemy import (
    Column, String, Boolean, DateTime, Date, Integer, Numeric, Text, ForeignKey, text
)
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from pgvector.sqlalchemy import Vector
from app.core.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    email = Column(String(255), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=True)
    full_name = Column(String(100), nullable=True)
    phone = Column(String(20), nullable=True)
    is_premium = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=text("CURRENT_TIMESTAMP"), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=text("CURRENT_TIMESTAMP"), nullable=False)

    profile = relationship("UserProfile", back_populates="user", uselist=False)


class UserProfile(Base):
    __tablename__ = "user_profiles"

    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    dietary_preference = Column(String(50), nullable=True)
    travel_style = Column(String(50), nullable=True)
    budget_tier = Column(String(30), nullable=True)
    pace_preference = Column(String(30), nullable=True)
    health_constraints = Column(JSONB, nullable=True)
    climate_sensitivities = Column(JSONB, nullable=True)
    raw_preference_notes = Column(Text, nullable=True)
    preference_vector = Column(Vector(384), nullable=True)

    user = relationship("User", back_populates="profile")


class TripGroup(Base):
    __tablename__ = "trip_groups"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    name = Column(String(150), nullable=False)
    cover_image_url = Column(Text, nullable=True)
    created_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    status = Column(String(30), default="planning", nullable=False)
    trip_start_date = Column(Date, nullable=True)
    trip_end_date = Column(Date, nullable=True)
    chat_retention_deadline = Column(Date, nullable=True)
    preserve_chat = Column(Boolean, default=False, nullable=False)

    consensus_profile = relationship("GroupConsensusProfile", back_populates="group", uselist=False)


class GroupConsensusProfile(Base):
    __tablename__ = "group_consensus_profiles"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    group_id = Column(UUID(as_uuid=True), ForeignKey("trip_groups.id", ondelete="CASCADE"), unique=True, nullable=False)
    computed_budget_range = Column(JSONB, nullable=True)
    hard_constraints = Column(JSONB, nullable=True)
    consensus_vector = Column(Vector(384), nullable=True)
    last_edited_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    is_locked_by_admin = Column(Boolean, default=False, nullable=False)

    group = relationship("TripGroup", back_populates="consensus_profile")


class Poll(Base):
    __tablename__ = "polls"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    group_id = Column(UUID(as_uuid=True), ForeignKey("trip_groups.id", ondelete="CASCADE"), nullable=False)
    created_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    question = Column(Text, nullable=False)
    status = Column(String(20), default="open", nullable=False)
    poll_vector = Column(Vector(384), nullable=True)


class InteractionEmbedding(Base):
    __tablename__ = "interaction_embeddings"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    group_id = Column(UUID(as_uuid=True), ForeignKey("trip_groups.id", ondelete="CASCADE"), nullable=False)
    source_type = Column(String(50), nullable=False)
    source_id = Column(UUID(as_uuid=True), nullable=True)
    summary_text = Column(Text, nullable=False)
    context_vector = Column(Vector(384), nullable=True)


class DestinationCatalog(Base):
    __tablename__ = "destinations_catalog"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    name = Column(String(150), nullable=False)
    state = Column(String(100), nullable=True)
    country = Column(String(100), nullable=True)
    tags = Column(JSONB, nullable=True)
    climate_type = Column(String(50), nullable=True)
    avg_daily_cost = Column(Numeric(10, 2), nullable=True)
    destination_vector = Column(Vector(384), nullable=True)
