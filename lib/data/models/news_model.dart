import '../../domain/entities/news.dart';

class NewsModel extends News {
  NewsModel({
    required super.id,
    required super.title,
    required super.summary,
    required super.content,
    required super.publishDate,
    required super.category,
    super.imageUrl,
    required super.author,
    super.tags,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
      content: json['content'],
      publishDate: DateTime.parse(json['publishDate']),
      category: json['category'],
      imageUrl: json['imageUrl'],
      author: json['author'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'publishDate': publishDate.toIso8601String(),
      'category': category,
      'imageUrl': imageUrl,
      'author': author,
      'tags': tags,
    };
  }

  static List<NewsModel> getMockNews() {
    return [
      NewsModel(
        id: 'news-1',
        title: 'Campus Library Extends Hours During Finals Week',
        summary:
            'The university library will be open 24/7 during finals week to accommodate student study needs.',
        content:
            'The university library will be open 24/7 during finals week to accommodate student study needs. Additional staff will be available to assist with research and technical support. Free coffee and snacks will be provided each night from 10 PM to 2 AM, courtesy of the Student Government Association. Study rooms can be reserved through the library website or mobile app.',
        publishDate: DateTime.now(),
        category: 'Announcement',
        author: 'Library Services',
        imageUrl:
            'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8bGlicmFyeXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60',
        tags: ['library', 'finals', 'study'],
      ),
      NewsModel(
        id: 'news-2',
        title: 'New Student Center Opening Next Month',
        summary:
            'The long-awaited student center will open its doors on May 15th with new dining options, study spaces, and recreational facilities.',
        content:
            'The long-awaited student center will open its doors on May 15th with new dining options, study spaces, and recreational facilities. The grand opening ceremony will feature live music and free food. The new facility includes a 24-hour study lounge, gaming area, meditation room, and six new dining options including a popular coffee chain and vegan café.',
        publishDate: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Campus Life',
        author: 'Campus Development',
        imageUrl:
            'https://images.unsplash.com/photo-1541829070764-84a7d30dd3f3?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8Y2FtcHVzfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=500&q=60',
        tags: ['student center', 'campus improvement', 'facilities'],
      ),
      NewsModel(
        id: 'news-3',
        title: 'Registration for Fall Semester Opens Next Week',
        summary:
            'Students can begin registering for Fall semester classes starting Monday.',
        content:
            'Students can begin registering for Fall semester classes starting Monday. Priority registration will be available based on class standing and academic program. Make sure to meet with your advisor before registration opens. The course catalog has been updated with several new classes across all departments. Registration will remain open through August 15th.',
        publishDate: DateTime.now().subtract(const Duration(days: 2)),
        category: 'Academic',
        author: 'Registrar\'s Office',
        imageUrl:
            'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NXx8c3R1ZGVudHN8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
        tags: ['registration', 'classes', 'fall semester'],
      ),
      NewsModel(
        id: 'news-4',
        title: 'University Receives \$5M Research Grant',
        summary:
            'The College of Science has been awarded a \$5 million grant for climate research.',
        content:
            'The College of Science has been awarded a \$5 million grant from the National Science Foundation to fund groundbreaking climate research. The grant will support a five-year project involving faculty and graduate students from multiple departments. This project aims to develop new models for predicting extreme weather events and their impact on urban infrastructure.',
        publishDate: DateTime.now().subtract(const Duration(days: 5)),
        category: 'Research',
        author: 'Research Office',
        imageUrl:
            'https://images.unsplash.com/photo-1507668077129-56e32842fceb?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8cmVzZWFyY2h8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
        tags: ['research', 'grant', 'climate', 'science'],
      ),
      NewsModel(
        id: 'news-5',
        title: 'Women\'s Basketball Team Heads to National Championship',
        summary:
            'Our women\'s basketball team has qualified for the national championship tournament.',
        content:
            'Our women\'s basketball team has qualified for the national championship tournament for the third consecutive year. The team finished the regular season with a record of 28-2 and won the conference championship last weekend. The first round of the national tournament begins next Thursday, with games being streamed live on the university website.',
        publishDate: DateTime.now().subtract(const Duration(days: 3)),
        category: 'Sports',
        author: 'Athletics Department',
        imageUrl:
            'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8YmFza2V0YmFsbHxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60',
        tags: ['basketball', 'championship', 'sports'],
      ),
    ];
  }
}
