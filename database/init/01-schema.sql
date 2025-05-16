CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'parent', 'teacher', 'kid')),
    profile_picture VARCHAR(255), -- Stores relative path to file, not full URL
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    oauth_provider VARCHAR(50),
    oauth_id VARCHAR(255)
);

CREATE TABLE verification_documents (
    document_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    document_path VARCHAR(255) NOT NULL, -- Stores relative path to file, not full URL
    is_approved BOOLEAN DEFAULT FALSE,
    approved_by INTEGER REFERENCES users(user_id),
    approved_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE user_profile (
    profile_id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    bio TEXT,
    specialty VARCHAR(100),
    experience_years INTEGER,
    total_xp INTEGER DEFAULT 0,
    is_approved BOOLEAN DEFAULT FALSE
);

CREATE TABLE kids (
    kid_id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    parent_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    birth_date DATE,
    total_xp INTEGER DEFAULT 0,
    is_restricted INTEGER DEFAULT 1
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon_path VARCHAR(255) -- Stores relative path to file, not full URL
);

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    teacher_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES categories(category_id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    thumbnail_path VARCHAR(255), -- Stores relative path to file, not full URL
    size_code CHAR(1) NOT NULL CHECK (size_code IN ('S', 'M', 'L', 'XL')),
    xp_reward INTEGER NOT NULL,
    min_age INTEGER,
    max_age INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE course_materials (
    material_id SERIAL PRIMARY KEY,
    course_id INTEGER REFERENCES courses(course_id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    file_path VARCHAR(255), -- Stores relative path to file, not full URL
    material_type VARCHAR(50) NOT NULL,
    order_index INTEGER
);

CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    kid_id INTEGER REFERENCES kids(kid_id) ON DELETE CASCADE,
    course_id INTEGER REFERENCES courses(course_id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    progress_percentage INTEGER DEFAULT 0,
    xp_earned INTEGER DEFAULT 0,
    UNIQUE(kid_id, course_id)
);

CREATE TABLE progress_logs (
    log_id SERIAL PRIMARY KEY,
    enrollment_id INTEGER REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    material_id INTEGER REFERENCES course_materials(material_id) ON DELETE CASCADE,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE course_ratings (
    rating_id SERIAL PRIMARY KEY,
    enrollment_id INTEGER REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE course_reports (
    report_id SERIAL PRIMARY KEY,
    enrollment_id INTEGER REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    teacher_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE xp_titles (
    title_id SERIAL PRIMARY KEY,
    title_name VARCHAR(50) NOT NULL,
    min_xp_required INTEGER NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('kid', 'teacher')),
    badge_path VARCHAR(255), -- Stores relative path to file, not full URL
    UNIQUE(title_name, role)
);

CREATE TABLE contact_messages (
    message_id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE
);

-- User Authentication
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- Course Discovery
CREATE INDEX idx_courses_teacher_id ON courses(teacher_id);
CREATE INDEX idx_courses_category_id ON courses(category_id);
CREATE INDEX idx_courses_age_range ON courses(min_age, max_age);

-- Kid Management
CREATE INDEX idx_kids_parent_id ON kids(parent_id);

-- Progress Tracking
CREATE INDEX idx_enrollments_kid_id ON enrollments(kid_id);
CREATE INDEX idx_enrollments_course_id ON enrollments(course_id);

