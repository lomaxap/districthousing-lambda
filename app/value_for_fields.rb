require 'date'

class ValueForField
  def value_of applicant, field_name
    case field_name
    when /^(.*?)_or_(.*?)$/
      value = value_of($1)
      return $2.gsub('_', ' ') if value == nil || value == ''
      value
    when /^HH(\d+)(.*)$/
      index = $1.to_i - 1
      household_member_val applicant['household_members'][index], $2
    when /^LL(\d+)(.*)$/
      ""
      index = $1.to_i - 1
      return "" if applicant['residences'][index].nil?
      person_val applicant['residences'][index]['landlord'], $2
    when /^Residence(\d+)(.*)$/
      index = $1.to_i - 1
      address_val applicant['addresses'][index], $2, applicant['residences']
    when /^Residence(.*)$/
      address_val applicant['addresses'][0], $1, applicant['residences']
    when /^Address(\d+)(.*)$/
      index = $1.to_i - 1
      address_val applicant['addresses'][index], $2, applicant['residences']
    when /^Address(.*)$/
      address_val applicant['addresses'][0], $1, applicant['residences']
    when /^Job(\d+)(.+)$/
      index = $1.to_i - 1
      employment_val applicant['employments'][index], $2
    when /^Job(.+)$/
      employment_val applicant['employments'][0], $1
    when /^Contact(\d+)(.+)$/
      ""
      # index = $1.to_i - 1
      # value_of applicant['contacts'][index], $2
    when /^Contact(.+)$/
      ""
      # value_of applicant['contacts'][0], $1
    when /^Income(\d+)(.+)$/
      index = $1.to_i - 1
      income_val applicant['incomes'][index], $2
    when /^Income(.+)$/
      income_val applicant['incomes'][0], $1
    when /^Crime(\d+)(.+)$/
      index = $1.to_i - 1
      criminal_history_val applicant['criminal_histories'][index], $2
    when /^Crime(.+)$/
      criminal_history_val applicant['criminal_histories'][0], $1
    else
      person_val(applicant['person'], field_name, applicant['addresses']) || ""
    end
  end

  private

  def household_member_val member, field_name
    return "" if member.nil?
    case field_name
    when "Relationship"
      member['relationship']
    else
      person_val member['member'], field_name
    end
  end

  def residence_val residence, field_name
    return "" if residence.nil?
    case field_name
    when "Start"
      residence['start_date']
    when "End"
      residence['end_date']
    when "ReasonForMoving"
      residence['reason']
    when "Rent"
      residence['rent']
      #helpers.number_to_currency(residence['rent'])
    else
      ""
    end
  end

  def address_val address, field_name, residences
    return "" if address.nil?
    case field_name
    when "Street"
      address['street']
    when "City"
      address['city']
    when "State"
      address['state']
    when "Zip"
      address['zip']
    when "Apt"
      case address['apt']
      when /^\d+[[:alpha:]]?$/ # For a string of digits without "Apartment" or "Unit" in the prefix
        "##{address['apt']}"
      when /^\w$/ # For single letter apartment numbers
        "##{address['apt']}"
      else # Otherwise, just use whatever they put
        address['apt']
      end
    when ""
      if /homeless/i.match address['street'].to_s
         "Homeless"
       elsif address['street'].to_s.empty? or address['city'].to_s.empty?
         ""
       else
         "#{address['street']}, #{address['apartment']}, #{address['city']}, #{address['state']}, #{address['zip']}".gsub(/( ,)+/, "").strip.sub(/,$/, "")
       end
    when /^(\D*)$/
      unless ['Street','City','State', 'Zip', 'Apt', ""].include?($1)
       residence_val residences.detect {|r| r['address_id'] == address['id']}, $1
      end
    end
  end

  def employment_val employment, field_name
    return "" if employment.nil?
    case field_name
    #when "Status"
    when "Title"
      employment['position']
    when "StartDate"
      employment['start_date']
    when "EndDate"
      employment['end_date']
    when "Employer"
      employment['employer_name']
    when "Phone"
      employment['phone']
    when /^(\D+)$/
      unless ['Status','Title','StartDate','EndDate','Employer','Phone'].include?($1)
        address_val employment['address'], $1, []
      end
    end
  end

  def income_val income, field_name
    return "" if income.nil?
    case field_name
    when "Source"
      income['income_type']
    when /^Amount$/
      income['amount'].to_i
    when "AmountWeekly"
      # always monthly form bread DB
      income['amount'].to_i/4.0
    when "AmountBiweekly"
      income['amount'].to_i/2.0
    when "AmountMonthly"
      income['amount'].to_i
    when "AmountYearly"
      income['amount'].to_i*12.0
    when "Interval"
      "monthly"
    when /^Earner(\D+)$/
      ""
      #person.value_for_field $1
    else
      ""
    end
  end

  def criminal_history_val history, field_name
    return "" if history.nil?
    case field_name
    when "Date"
      history['year']
    when "Type"
      history['crime_type']
      #Constants::CrimeType.new(history['crime_type']).name_pdf
    when "Description"
      history['description']
    when "State"
      history['state']
    when /^(\D+)$/
      ""
      #person.value_for_field $1
    else
      ""
    end
  end

  def person_val person, field_name, *addresses
    return "" if person.nil?
    case field_name
    when /^Mail(.*)/
      return "" if addresses.nil? || person['mailing_address_id'].nil?
      index = person['mailing_address_id'].to_i
      address_val(addresses[index], $1, person['residences'])
    when /^Address(.*)/
      return "" if addresses.nil? || person['mailing_address_id'].nil?
      index = person['mailing_address_id'].to_i
      address_val(addresses[index], $1, person['residences'])
    when "FirstName"
      person['first_name']
    when "FirstInitial"
      return "" if person['first_name'].nil?
      i = person['first_name'].to_s[0]
      i && i.upcase
    when "LastName"
      person['last_name']
    when "LastInitial"
      return "" if person['last_name'].nil?
      i = person['last_name'].to_s[0]
      i && i.upcase
    when "MiddleName"
      person['middle_name']
    when "MiddleInitial"
      return "" if person['middle_name'].nil?
      i = person['middle_name'].to_s[0]
      i && i.upcase
    when /^(Full)?Name\d*$/
      "#{person['first_name']} #{person['middle_name']} #{person['last_name']}".strip.squeeze(" ")
    when "DOB"
      return "" if person['dob'].nil?
      Date.parse(person['dob']).strftime("%m/%d/%Y")
    when "DOBDD"
      return "" if person['dob'].nil?
      Date.parse(person['dob']).strftime("%d")
    when "DOBMM"
      return "" if person['dob'].nil?
      Date.parse(person['dob']).strftime("%m")
    when "DOBYYYY"
      return "" if person['dob'].nil?
      Date.parse(person['dob']).strftime("%Y")
    when "Age"
      return "" if person['dob'].nil?
      now = Time.now.utc.to_date
      now.year - Date.parse(person['dob']).year - ((now.month > Date.parse(person['dob']).month || (now.month == Date.parse(person['dob']).month && now.day >= Date.parse(person['dob']).day)) ? 0 : 1)
    when "SSN"
      person['ssn']
    when "WorkPhone"
      person['work_phone']
    when "CellPhone"
      person['cell_phone']
    when "HomePhone"
      person['home_phone']
    when /^(Preferred)?Phone$/
      ""
      #person['preferred_phone']
    when "Email"
      person['email']
    when "GenderInitial"
      return "" if person['gender'].nil?
      i = person['gender'].to_s[0]
      i && i.upcase
    when "Gender"
      person['gender']
    when "Race"
      person['race']
      #Constants::Race.new(person['race']).name_pdf
    when /RaceAsian((Yes|No|Y|N|T|F|TickYes|TickNo)+$)/
      boolean_field $1 do person['race'] == "Asian" end
    when /RaceBlack((Yes|No|Y|N|T|F|TickYes|TickNo)+$)/
      boolean_field $1 do person['race'] == "Black" end
    when /RaceNativeAmerican((Yes|No|Y|N|T|F|TickYes|TickNo)+$)/
      boolean_field $1 do person['race'] == "NativeAmerican" end
    when /RaceOther((Yes|No|Y|N|T|F|TickYes|TickNo)+$)/
      boolean_field $1 do person['race'] == "Other" end
    when /RacePacificIslander((Yes|No|Y|N|T|F|TickYes|TickNo)+$)/
      boolean_field $1 do person['race'] == "PacificIslander" end
    when /RaceWhite((Yes|No|Y|N|T|F|TickYes|TickNo)+$)/
      boolean_field $1 do person['race'] == "White" end
    when /RaceDecline((Yes|No|Y|N|T|F|TickYes|TickNo)+$)/
      boolean_field $1 do person['race'] == "Decline" end
    when "Ethnicity"
      person['ethnicity']
      #Constants::Ethnicity.new(person['ethnicity']).name_pdf
    when /EthnicityHispanic((Yes|No|Y|N|T|F|TickYes|TickNo)+$)/
      boolean_field $1 do person['ethnicity'] == "Hispanic" end
    when /EthnicityNotHispanic((Yes|No|Y|N|T|F|TickYes|TickNo)+$)/
      boolean_field $1 do person['ethnicity'] == "NotHispanic" end
    when /EthnicityDecline((Yes|No|Y|N|T|F|TickYes|TickNo)+$)/
      boolean_field $1 do person['ethnicity'] == "Decline" end
    when "CountryOfBirth"
      person['country_of_birth']
    when "BirthState"
      person['state_of_birth']
    when "BirthCity"
      person['city_of_birth']
    when "MaritalStatus"
      person['marital_status']
    when "StudentStatus"
      person['student_status']
    when "Occupation"
      person['occupation']
    when "Citizenship"
      person['citizenship']
    when "Nationality"
      person['citizenship'] # Synonymous with Citizenship
    when /USCitizen((Yes|No|Y|N|T|F|TickYes|TickNo)+$)/
      boolean_field $1 do "US Citizen" == person['citizenship'] end
    when "DriverLicense"
      person['driver_license_number']
    when "DriverLicenseState"
      person['driver_license_state']
    when "DriverLicenseExpire"
      return "" if person['driver_license_exp_date'].nil?
      person['driver_license_exp_date'].strftime("%m/%d/%Y")
    when "DriverLicenseExpireDD"
      return "" if person['driver_license_exp_date'].nil?
      person['driver_license_exp_date'].strftime("%d")
    when "DriverLicenseExpireMM"
      return "" if person['driver_license_exp_date'].nil?
      person['driver_license_exp_date'].strftime("%m")
    when "DriverLicenseExpireYYYY"
      return "" if person['driver_license_exp_date'].nil?
      person['driver_license_exp_date'].strftime("%Y")
    when "Relationship"
      "Self"
    when /Married((Yes|No|Y|N|T|F|TickYes|TickNo)+$)/
      boolean_field $1 do person['marital_status'] == "Married" end
    when /Separated((Yes|No|Y|N|T|F|TickYes|TickNo)+$)/
      boolean_field $1 do person['marital_status'] == "Separated" end
    when /Single((Yes|No|Y|N|T|F|TickYes|TickNo)+$)/
      boolean_field $1 do person['marital_status'] == "Single" end
    when /Divorced((Yes|No|Y|N|T|F|TickYes|TickNo)+$)/
      boolean_field $1 do person['marital_status'] == "Divorced" end
    when /Widowed((Yes|No|Y|N|T|F|TickYes|TickNo)+$)/
      boolean_field $1 do person['marital_status'] == "Widowed" end
    when /StudentStatus((Yes|No|Y|N|T|F|TickYes|TickNo)+$)/
      boolean_field $1 do person['student_status'] == "Full-time" or person['student_status'] == "Part-time" end
    when /StudentStatusFullTime((Yes|No|Y|N|T|F|TickYes|TickNo)+$)/
      boolean_field $1 do person['student_status'] == "Full-time" end
    when /GenderMale((Yes|No|Y|N|T|F|TickYes|TickNo)+$)/
      boolean_field $1 do person['gender'] == "Male" end
    when /GenderFemale((Yes|No|Y|N|T|F|TickYes|TickNo)+$)/
      boolean_field $1 do person['gender'] == "Female" end
    else
      ""
      #UnknownField.new
    end
  end

  def boolean_field boolean_field_component
    truth = yield
    if truth
      case boolean_field_component
      when /^(Tick)?Yes(No)?$|^T$/
        "Yes"
      when /^Y$|^YN$/
        "Y"
      else
        ""
      end
    else
      case boolean_field_component
      when /^TickNo$/
        "Yes"
      when /^(Yes)?No$/
        "No"
      when /^N$|^YN$/
        "N"
      else
        ""
      end
    end
  end
end
