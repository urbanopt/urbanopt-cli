#*********************************************************************************
# URBANopt™, Copyright (c) 2019-2020, Alliance for Sustainable Energy, LLC, and other
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
#*********************************************************************************

require 'urbanopt/reporting'

require_relative 'Baseline'

require 'json'

module URBANopt
  module Scenario
    class FlexibleHotWaterMapper < BaselineMapper

      def create_osw(scenario, features, feature_names)

        osw = super(scenario, features, feature_names)

        feature = features[0]
        building_type = feature.building_type

        # Only apply to commercial buildings, not residential models
        if commercial_building_types.include? building_type
          OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', '__SKIP__', false)
          # Add a sizing multiplier to the tank capacity to cover flex periods
          OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'vol', 2)
          # Update maximum tank and minimum temperature setpoints
          OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'max_temp', 185)
          OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'min_temp', 125)

          # Manage water heat charge float periods by building
          OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'flex0', 'Charge - Heat Pump')
          OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'flex_hrs0', '16:00-17:00')
          OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'flex1', 'Float')
          OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'flex_hrs1', '17:01-19:00')
        end

        return osw
      end

    end
  end
end
