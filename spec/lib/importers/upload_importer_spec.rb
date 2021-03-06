require 'rails_helper'
require "#{Rails.root}/lib/importers/upload_importer"

describe UploadImporter do
  describe '.import_all_uploads' do
    it 'should find and record files uploaded to Commons' do
      create(:user,
             username: 'Guettarda')
      VCR.use_cassette 'commons/import_all_uploads' do
        UploadImporter.import_all_uploads(User.all)
        expect(CommonsUpload.all.count).to be > 50
      end
    end
  end

  describe '.update_usage_count_by_course' do
    before do
      user = create(:user,
                    username: 'Guettarda')
      course = create(:course, start: '2006-01-01', end: '2007-01-01')
      create(:courses_user, course_id: course.id, user_id: user.id,
                            role: CoursesUsers::Roles::STUDENT_ROLE)
    end

    it 'should count and record how many times files are used' do
      VCR.use_cassette 'commons/import_all_uploads' do
        UploadImporter.import_all_uploads(User.all)
      end
      VCR.use_cassette 'commons/update_usage_count' do
        UploadImporter.update_usage_count_by_course(Course.all)
        peas_photo = CommonsUpload.find(543972)
        expect(peas_photo.usage_count).to be > 1
      end
    end
  end

  describe '.find_deleted_files' do
    before do
      create(:commons_upload, id: 4)
      create(:commons_upload, id: 20523186)
      VCR.use_cassette 'commons/find_deleted_files' do
        UploadImporter.find_deleted_files(CommonsUpload.all)
      end
    end

    it 'marks missing files as deleted' do
      missing_file = CommonsUpload.find(4)
      expect(missing_file.deleted).to eq(true)
    end

    it 'does not affect non-deleted files' do
      existing_file = CommonsUpload.find(20523186)
      expect(existing_file.deleted).to eq(false)
    end
  end

  describe '.import_urls_in_batches' do
    it 'should find and record Commons thumbnail urls' do
      create(:user,
             username: 'Guettarda')
      VCR.use_cassette 'commons/import_all_uploads' do
        UploadImporter.import_all_uploads(User.all)
      end
      VCR.use_cassette 'commons/import_urls_in_batches' do
        UploadImporter.import_urls_in_batches([CommonsUpload.find(543972)])
        peas_photo = CommonsUpload.find(543972)
        expect(peas_photo.thumburl[0...24]).to eq('https://upload.wikimedia')
      end
    end
  end
end
