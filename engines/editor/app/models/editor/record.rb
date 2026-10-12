# frozen_string_literal: true
module Editor
  # Minimal persistence for models stored in Editor::Store. Attributes are
  # stored as plain JSON data and rehydrated into model instances on read.
  class Record
    include ActiveModel::Model
    include ActiveModel::Attributes

    class RecordNotFound < StandardError; end

    attribute :id, :integer
    attribute :created_at, :datetime

    class << self
      def all
        Store.synchronize { collection.values.map { |attrs| load(attrs) } }.sort_by(&:id)
      end

      def where(**conditions)
        all.select { |record| conditions.all? { |key, value| Array(value).include?(record.public_send(key)) } }
      end

      def find(id)
        attrs = Store.synchronize { collection[id.to_s] }
        raise RecordNotFound, "Couldn't find #{name} with id=#{id}" unless attrs

        load(attrs)
      end

      def create!(**attrs)
        new(**attrs).tap(&:save!)
      end

      def collection
        Store.collection(name)
      end

      # Stored data may include attributes from earlier versions of the model.
      def load(attrs)
        new(attrs.slice(*attribute_names))
      end
    end

    def persisted?
      id.present?
    end

    def save!
      raise ActiveModel::ValidationError, self unless valid?

      Store.synchronize do
        self.id ||= Store.next_id
        self.created_at ||= Time.current
        self.class.collection[id.to_s] = attributes.transform_values { |value| value.respond_to?(:iso8601) ? value.iso8601(6) : value }
        Store.persist!
      end
      self
    end

    def update!(**attrs)
      assign_attributes(attrs)
      save!
    end

    def destroy
      Store.synchronize do
        self.class.collection.delete(id.to_s)
        Store.persist!
      end
    end

    def ==(other)
      other.instance_of?(self.class) && other.id == id
    end
  end
end
