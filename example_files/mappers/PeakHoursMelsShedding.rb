# *********************************************************************************
# URBANopt™, Copyright (c) 2019-2022, Alliance for Sustainable Energy, LLC, and other
# contributors. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# Redistributions of source code must retain the above copyright notice, this list
# of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright notice, this
# list of conditions and the following disclaimer in the documentation and/or other
# materials provided with the distribution.
#
# Neither the name of the copyright holder nor the names of its contributors may be
# used to endorse or promote products derived from this software without specific
# prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.
# *********************************************************************************
# Mapper created by LBNL using the measure from openstudio-geb gem
# (https://github.com/LBNL-ETA/Openstudio-GEB-gem)
# *********************************************************************************

require 'urbanopt/reporting'
require 'openstudio/geb'

require_relative 'Baseline'

require 'json'

module URBANopt
  module Scenario
    class PeakHoursMelsSheddingMapper < BaselineMapper
      # The measure reduces electric equipment loads by a user-specified percentage for a user-specified time period (usually the peak hours).
      # The reduction can be applied to at most three periods throughout out the year specified by the user.
      # This is applied throughout the entire building.
      def create_osw(scenario, features, feature_names)
        osw = super(scenario, features, feature_names)
        OpenStudio::Extension.set_measure_argument(osw, 'reduce_epd_by_percentage_for_peak_hours', '__SKIP__', false)
        # Percentage Reduction of Electric Equipment Power (%). Enter a value between 0 and 100
        OpenStudio::Extension.set_measure_argument(osw, 'reduce_epd_by_percentage_for_peak_hours', 'epd_reduce_percent', 50.0)
        # Starting Time for the Reduction in HH:MM:SS format
        OpenStudio::Extension.set_measure_argument(osw, 'reduce_epd_by_percentage_for_peak_hours', 'start_time', '17:00:00')
        # End Time for the Reduction in HH:MM:SS format
        OpenStudio::Extension.set_measure_argument(osw, 'reduce_epd_by_percentage_for_peak_hours', 'end_time', '21:00:00')

        # First Starting Date for the Reduction in MM-DD format
        OpenStudio::Extension.set_measure_argument(osw, 'reduce_epd_by_percentage_for_peak_hours', 'start_date1', '07-01')
        # First End Date for the Reduction in MM-DD format
        OpenStudio::Extension.set_measure_argument(osw, 'reduce_epd_by_percentage_for_peak_hours', 'end_date1', '08-31')
        # Second Starting Date for the Reduction in MM-DD format. Leave it blank if not needed
        # OpenStudio::Extension.set_measure_argument(osw, 'reduce_epd_by_percentage_for_peak_hours', 'start_date2', '')
        # Second End Date for the Reduction in MM-DD format. Leave it blank if not needed
        # OpenStudio::Extension.set_measure_argument(osw, 'reduce_epd_by_percentage_for_peak_hours', 'end_date2', '')
        # Third Starting Date for the Reduction in MM-DD format. Leave it blank if not needed
        # OpenStudio::Extension.set_measure_argument(osw, 'reduce_epd_by_percentage_for_peak_hours', 'start_date3', '')
        # Third End Date for the Reduction in MM-DD format. Leave it blank if not needed
        # OpenStudio::Extension.set_measure_argument(osw, 'reduce_epd_by_percentage_for_peak_hours', 'end_date3', '')
        return osw
      end
    end
  end
end
