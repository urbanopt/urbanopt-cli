# frozen_string_literal: true

class Constants
  def self.Auto
    'auto'
  end

  def self.CoordRelative
    'relative'
  end

  def self.FacadeFront
    'front'
  end

  def self.FacadeBack
    'back'
  end

  def self.FacadeLeft
    'left'
  end

  def self.FacadeRight
    'right'
  end

  # Numbers --------------------

  def self.NumDaysInMonths(is_leap_year = false)
    num_days_in_months = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    num_days_in_months[1] += 1 if is_leap_year
    num_days_in_months
  end

  def self.NumDaysInYear(is_leap_year = false)
    num_days_in_months = NumDaysInMonths(is_leap_year)
    num_days_in_year = num_days_in_months.reduce(:+)
    num_days_in_year.to_f
  end

  def self.NumHoursInYear(is_leap_year = false)
    num_days_in_year = NumDaysInYear(is_leap_year)
    num_hours_in_year = num_days_in_year * 24
    num_hours_in_year.to_f
  end

  def self.NumApplyUpgradeOptions
    25
  end

  def self.NumApplyUpgradesCostsPerOption
    2
  end
end
