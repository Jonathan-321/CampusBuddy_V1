import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Service to interact with Claude API
class ClaudeApiService {
  // Direct API URL
  final String baseUrl = 'https://api.anthropic.com/v1/messages';

  // CORS proxy URL for web platform - this is a public CORS proxy for development
  // In production, you should use your own backend proxy
  final String corsProxyUrl =
      'https://cors-anywhere.herokuapp.com/https://api.anthropic.com/v1/messages';

  final String apiKey;
  final String model;

  ClaudeApiService({
    required this.apiKey,
    this.model = 'claude-3-haiku-20240307',
  });

  /// Send a message to Claude API with conversation history for context
  Future<Map<String, dynamic>> sendMessage({
    required String userMessage,
    required List<Map<String, String>> messageHistory,
    double temperature = 0.7,
    int maxTokens = 1024,
    String systemPrompt = 'You are Campus Buddy, the official AI assistant for Oklahoma Christian University students. '
        'You have comprehensive and authoritative information about Oklahoma Christian University (OC) including: '
        'course offerings, class schedules, academic departments, campus locations, contact information, '
        'housing options, meal plans, upcoming events, services, and important academic dates. '
        'When answering questions about course offerings and schedules: '
        '- Provide specific details about what classes are being offered in the current or upcoming semesters '
        '- State when classes are scheduled (days, times, building locations) '
        '- Identify which professors are teaching specific courses when known '
        '- Include information about course prerequisites and credit hours '
        '- Reference registration deadlines and procedures '
        '- Suggest related or complementary courses when relevant '
        'Be confident and direct with your knowledge. Do not use phrases like "I believe," "I think," or "I\'m not sure." '
        'If information is factual and in your knowledge base, state it authoritatively. '
        'Never apologize for providing information that\'s correct and helpful. '
        'When answering questions, always prioritize Oklahoma Christian University data provided to you. '
        'Be comprehensive about OC\'s academic colleges, departments, programs, course offerings, and degree requirements. '
        'Provide specific details like room numbers, phone numbers, email addresses, operating hours, costs, and deadlines. '
        'Focus on helping students navigate academic planning, course selection, and registration. '
        'For student life questions, provide detailed information about OC\'s housing options, meal plans, spiritual life, and athletics. '
        'If asked about something for which you genuinely don\'t have specific information, briefly acknowledge this '
        'and immediately suggest the most relevant OC resource (specific department, office, website) where the student can find that information. '
        'Always respond in the same language as the user\'s message. '
        'If the user\'s message is in English, respond in English. '
        'If the user\'s message is in Spanish, respond in Spanish. '
        'If the user\'s message is in French, respond in French. '
        'If the user\'s message is in Kinyarwanda, respond in Kinyarwanda.',
    Map<String, dynamic>? universityData,
  }) async {
    try {
      // For web platform, we need to handle CORS issues
      // In a real-world scenario, you should have a backend proxy
      final effectiveUrl = kIsWeb ? corsProxyUrl : baseUrl;

      // Headers for the request
      final headers = {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      };

      // For web platform using the CORS proxy, we need to add additional headers
      if (kIsWeb) {
        headers['Origin'] = 'https://campus-buddy.example.com';
        headers['X-Requested-With'] = 'XMLHttpRequest';
      }

      // Enhance system prompt with university data if provided
      String enhancedSystemPrompt = systemPrompt;
      if (universityData != null) {
        enhancedSystemPrompt +=
            '\n\nHere is the specific data about Oklahoma Christian University that you should use when answering questions:';

        // Add university info
        if (universityData['universityInfo'] != null) {
          final info = universityData['universityInfo'];
          enhancedSystemPrompt +=
              '\n\nUniversity Information: ${info['name']} (${info['abbreviation']}), ${info['address']}, Phone: ${info['phone']}, Email: ${info['email']}, Website: ${info['website']}';
        }

        // Add academic information
        if (universityData['academics'] != null) {
          enhancedSystemPrompt += '\n\nAcademic Information:';
          final academics = universityData['academics'];

          // Add colleges and schools
          if (academics['collegesAndSchools'] != null) {
            enhancedSystemPrompt += '\nColleges and Schools:';
            for (var college in academics['collegesAndSchools']) {
              enhancedSystemPrompt +=
                  '\n- ${college['name']}: Departments: ${college['departments'].join(', ')}. Contact: ${college['contact']['phone']}, ${college['contact']['email']}';
            }
          }

          // Add course offerings
          if (academics['courseOfferings'] != null) {
            enhancedSystemPrompt += '\n\nCourse Offerings:';
            academics['courseOfferings'].forEach((term, courses) {
              enhancedSystemPrompt += '\n$term:';
              for (var course in courses) {
                enhancedSystemPrompt +=
                    '\n- ${course['courseCode']}: ${course['title']} (${course['creditHours']} credit hours) - ${course['description']}';
                enhancedSystemPrompt += '\n  Sections:';
                for (var section in course['sections']) {
                  enhancedSystemPrompt +=
                      '\n  * Section ${section['sectionNumber']}: ${section['professor']}, ${section['schedule']}, ${section['location']}';
                }
                if (course['prerequisites'].isNotEmpty) {
                  enhancedSystemPrompt +=
                      '\n  Prerequisites: ${course['prerequisites'].join(', ')}';
                }
              }
            });
          }

          // Add registration info
          if (academics['registrationInfo'] != null) {
            final regInfo = academics['registrationInfo'];
            enhancedSystemPrompt +=
                '\n\nRegistration Information: ${regInfo['process']} ${regInfo['registrationHelp']} ${regInfo['advisingInfo']}';
          }
        }

        // Add important dates
        if (universityData['importantDates'] != null) {
          enhancedSystemPrompt += '\n\nImportant Dates:';
          final dates = universityData['importantDates'];

          // Academic calendar
          if (dates['academicCalendar'] != null) {
            enhancedSystemPrompt += '\nAcademic Calendar:';
            dates['academicCalendar'].forEach((term, termDates) {
              enhancedSystemPrompt += '\n$term:';
              termDates.forEach((event, date) {
                enhancedSystemPrompt += '\n- $event: $date';
              });
            });
          }

          // Registration dates
          if (dates['registrationDates'] != null) {
            enhancedSystemPrompt += '\nRegistration Dates:';
            dates['registrationDates'].forEach((term, regDates) {
              enhancedSystemPrompt += '\n$term:';
              regDates.forEach((group, date) {
                enhancedSystemPrompt += '\n- $group: $date';
              });
            });
          }
        }

        // Add housing information
        if (universityData['housing'] != null) {
          enhancedSystemPrompt += '\n\nHousing Information:';
          final housing = universityData['housing'];

          // Residence halls
          if (housing['residenceHalls'] != null) {
            enhancedSystemPrompt += '\nResidence Halls:';

            enhancedSystemPrompt += '\nWomen\'s Halls:';
            for (var hall in housing['residenceHalls']['women']) {
              enhancedSystemPrompt +=
                  '\n- ${hall['name']}: ${hall['type']}, Cost: ${hall['cost']}, For: ${hall['yearLevels'].join(', ')}';
            }

            enhancedSystemPrompt += '\nMen\'s Halls:';
            for (var hall in housing['residenceHalls']['men']) {
              enhancedSystemPrompt +=
                  '\n- ${hall['name']}: ${hall['type']}, Cost: ${hall['cost']}, For: ${hall['yearLevels'].join(', ')}';
            }
          }

          // Apartments
          if (housing['apartments'] != null) {
            enhancedSystemPrompt += '\nApartments:';

            enhancedSystemPrompt += '\nWomen\'s Apartments:';
            for (var apt in housing['apartments']['women']) {
              enhancedSystemPrompt +=
                  '\n- ${apt['name']}: ${apt['type']}, Cost: ${apt['cost']}, For: ${apt['yearLevels'].join(', ')}';
            }

            enhancedSystemPrompt += '\nMen\'s Apartments:';
            for (var apt in housing['apartments']['men']) {
              enhancedSystemPrompt +=
                  '\n- ${apt['name']}: ${apt['type']}, Cost: ${apt['cost']}, For: ${apt['yearLevels'].join(', ')}';
            }
          }

          // Housing office
          if (housing['housingOffice'] != null) {
            final office = housing['housingOffice'];
            enhancedSystemPrompt +=
                '\nHousing Office: ${office['name']}, Phone: ${office['phone']}, Email: ${office['email']}';
          }
        }

        // Add dining information
        if (universityData['dining'] != null) {
          enhancedSystemPrompt += '\n\nDining Information:';
          final dining = universityData['dining'];

          // Dining locations
          if (dining['locations'] != null) {
            enhancedSystemPrompt += '\nDining Locations:';
            for (var location in dining['locations']) {
              enhancedSystemPrompt +=
                  '\n- ${location['name']}: ${location['type']}';
              if (location['description'] != null) {
                enhancedSystemPrompt += ', ${location['description']}';
              }
            }
          }

          // Meal plans
          if (dining['mealPlans'] != null) {
            enhancedSystemPrompt += '\nMeal Plans:';

            enhancedSystemPrompt += '\nApartment Plans:';
            for (var plan in dining['mealPlans']['apartmentPlans']) {
              enhancedSystemPrompt += '\n- ${plan['name']}: ${plan['cost']}';
            }

            enhancedSystemPrompt += '\nResidence Hall Plans:';
            for (var plan in dining['mealPlans']['residenceHallPlans']) {
              enhancedSystemPrompt += '\n- ${plan['name']}: ${plan['cost']}';
            }
          }
        }

        // Add campus resources
        if (universityData['campusResources'] != null) {
          enhancedSystemPrompt += '\n\nCampus Resources:';
          final resources = universityData['campusResources'];

          // Library
          if (resources['library'] != null) {
            final lib = resources['library'];
            enhancedSystemPrompt +=
                '\nLibrary: ${lib['name']}, Phone: ${lib['phone']}, Email: ${lib['email']}';
            enhancedSystemPrompt += '\nHours:';
            lib['hours'].forEach((day, hours) {
              enhancedSystemPrompt += '\n- $day: $hours';
            });
          }

          // Student support
          if (resources['studentSupport'] != null) {
            enhancedSystemPrompt += '\nStudent Support Services:';
            resources['studentSupport'].forEach((service, info) {
              enhancedSystemPrompt += '\n- $service: ${info['description']}';
            });
          }
        }

        // Add upcoming events
        if (universityData['upcomingEvents'] != null) {
          enhancedSystemPrompt += '\n\nUpcoming Events:';
          for (var event in universityData['upcomingEvents']) {
            enhancedSystemPrompt += '\n- ${event['name']}: ${event['date']}';
            if (event['time'] != null) {
              enhancedSystemPrompt += ', ${event['time']}';
            }
            if (event['description'] != null) {
              enhancedSystemPrompt += ' - ${event['description']}';
            }
          }
        }
      }

      // Make the API request
      final response = await http.post(
        Uri.parse(effectiveUrl),
        headers: headers,
        body: jsonEncode({
          'model': model,
          'messages': messageHistory,
          'system': enhancedSystemPrompt,
          'max_tokens': maxTokens,
          'temperature': temperature,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'API Error: ${errorData['error']['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('Error sending message to Claude API: $e');
      if (kIsWeb) {
        // Provide a mock response for web platform during development
        return {
          'content': [
            {
              'text':
                  "I'm sorry, I couldn't connect to the Claude API from your web browser due to CORS restrictions. Please try using the mobile app for a better experience."
            }
          ]
        };
      }
      rethrow;
    }
  }
}
