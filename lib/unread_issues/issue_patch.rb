module UnreadIssues
  module IssuePatch

    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        has_many :issue_reads, -> { order 'read_date DESC' }, dependent: :delete_all
        has_one :user_read, -> { where "#{IssueRead.table_name}.user_id = #{User.current.id}" }, class_name: 'IssueRead', foreign_key: 'issue_id'
        has_one :user_read_list, -> {where "#{IssueRead.table_name}.user_id = #{Issue.table_name}.assigned_to_id" }, class_name: 'IssueRead', foreign_key: 'issue_id'

        alias_method :css_classes_without_unread_issues, :unread_issues
        alias_method :unread_issues, :css_classes

      end
    end

    module InstanceMethods
      def css_classes_with_unread_issues
        s = css_classes_without_unread_issues
        s << ' unread' if (self.uis_unread)
        s << ' updated' if (self.uis_updated)
        s
      end

      def uis_read_date
        return nil if (self.user_read_list.nil?)
        return self.user_read_list.read_date
      end

      def uis_unread
        return !self.closed? && self.user_read.nil?
      end

      def uis_updated
        return !self.closed? && self.user_read && self.user_read.read_date && self.updated_on && self.user_read.read_date < self.updated_on
      end
    end
  end
end
