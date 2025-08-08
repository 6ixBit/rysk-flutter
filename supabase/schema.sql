-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (extends Supabase auth.users)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS (Row Level Security)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Documents table
CREATE TABLE public.documents (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'uploading' CHECK (status IN ('uploading', 'processing', 'completed', 'failed')),
  upload_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  processed_date TIMESTAMP WITH TIME ZONE,
  error_message TEXT,
  
  -- Document content
  extracted_text TEXT,
  page_count INTEGER DEFAULT 1,
  file_size_bytes BIGINT,
  
  -- Analysis results
  overall_risk_score DECIMAL(5,2) CHECK (overall_risk_score >= 0 AND overall_risk_score <= 100),
  risk_level TEXT CHECK (risk_level IN ('Low', 'Medium', 'High', 'Critical')),
  
  -- Metadata
  metadata JSONB DEFAULT '{}',
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for documents
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;

-- Documents policies
CREATE POLICY "Users can view own documents" ON public.documents
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own documents" ON public.documents
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own documents" ON public.documents
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own documents" ON public.documents
  FOR DELETE USING (auth.uid() = user_id);

-- Document images table
CREATE TABLE public.document_images (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  document_id UUID REFERENCES public.documents(id) ON DELETE CASCADE NOT NULL,
  image_url TEXT NOT NULL,
  page_number INTEGER NOT NULL DEFAULT 1,
  file_name TEXT,
  file_size_bytes BIGINT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for document images
ALTER TABLE public.document_images ENABLE ROW LEVEL SECURITY;

-- Document images policies
CREATE POLICY "Users can view own document images" ON public.document_images
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.documents 
      WHERE documents.id = document_images.document_id 
      AND documents.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own document images" ON public.document_images
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.documents 
      WHERE documents.id = document_images.document_id 
      AND documents.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own document images" ON public.document_images
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.documents 
      WHERE documents.id = document_images.document_id 
      AND documents.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own document images" ON public.document_images
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.documents 
      WHERE documents.id = document_images.document_id 
      AND documents.user_id = auth.uid()
    )
  );

-- Risky clauses table
CREATE TABLE public.risky_clauses (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  document_id UUID REFERENCES public.documents(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  clause_text TEXT NOT NULL,
  risk_level INTEGER NOT NULL CHECK (risk_level >= 1 AND risk_level <= 10),
  explanation TEXT,
  recommendations TEXT[] DEFAULT '{}',
  
  -- Position in document
  page_number INTEGER,
  position_start INTEGER,
  position_end INTEGER,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for risky clauses
ALTER TABLE public.risky_clauses ENABLE ROW LEVEL SECURITY;

-- Risky clauses policies
CREATE POLICY "Users can view own risky clauses" ON public.risky_clauses
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.documents 
      WHERE documents.id = risky_clauses.document_id 
      AND documents.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own risky clauses" ON public.risky_clauses
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.documents 
      WHERE documents.id = risky_clauses.document_id 
      AND documents.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own risky clauses" ON public.risky_clauses
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.documents 
      WHERE documents.id = risky_clauses.document_id 
      AND documents.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own risky clauses" ON public.risky_clauses
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.documents 
      WHERE documents.id = risky_clauses.document_id 
      AND documents.user_id = auth.uid()
    )
  );

-- Function to handle user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on user signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

CREATE TRIGGER update_documents_updated_at
  BEFORE UPDATE ON public.documents
  FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- Indexes for better performance
CREATE INDEX idx_documents_user_id ON public.documents(user_id);
CREATE INDEX idx_documents_status ON public.documents(status);
CREATE INDEX idx_documents_upload_date ON public.documents(upload_date DESC);
CREATE INDEX idx_document_images_document_id ON public.document_images(document_id);
CREATE INDEX idx_risky_clauses_document_id ON public.risky_clauses(document_id);
CREATE INDEX idx_risky_clauses_risk_level ON public.risky_clauses(risk_level DESC);

-- Storage bucket for document images
INSERT INTO storage.buckets (id, name, public) VALUES ('document-images', 'document-images', false);

-- Storage policies
CREATE POLICY "Users can upload their own document images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'document-images' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can view their own document images" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'document-images' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete their own document images" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'document-images' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  ); 