import 'package:flutter/material.dart';

class QuizQuestions {
  static List<Map<String, dynamic>> getQuestionsForQuiz(String title) {
    switch (title) {
      case "Blockchain Basics":
        return [
          {
            'question': 'What is blockchain like?',
            'options': [
              'A digital notebook everyone can see',
              'A secret diary',
              'A single computer',
              'A type of video game',
            ],
            'answer': 'A digital notebook everyone can see',
          },
          {
            'question': 'Who controls the blockchain?',
            'options': [
              'The government',
              'Banks',
              'No single person - it\'s decentralized',
              'A secret organization',
            ],
            'answer': 'No single person - it\'s decentralized',
          },
          {
            'question': 'What makes blockchain secure?',
            'options': [
              'It\'s kept in a vault',
              'It uses magic',
              'Everyone has a copy and checks transactions',
              'Only one person can access it',
            ],
            'answer': 'Everyone has a copy and checks transactions',
          },
          {
            'question': 'What is a smart contract?',
            'options': [
              'A digital agreement that runs on the blockchain',
              'A type of bank account',
              'A contract with a lawyer',
              'A smart device',
            ],
            'answer': 'A digital agreement that runs on the blockchain',
          },
        ];
      case "Fraud Awareness":
        return [
          {
            'question': 'Who controls the blockchain?',
            'options': [
              'The government',
              'No single person - it\'s decentralized',
              'Banks',
              'A secret organization',
            ],
            'answer': 'No single person - it\'s decentralized',
          },
          {
            'question': 'What makes blockchain secure?',
            'options': [
              'It\'s kept in a vault',
              'It uses magic',
              'Everyone has a copy and checks transactions',
              'Only one person can access it',
            ],
            'answer': 'Everyone has a copy and checks transactions',
          },
        ];
      case "Banking Essentials":
        return [
          {
            'question': 'What is a checking account used for?',
            'options': [
              'Saving long-term',
              'Everyday transactions',
              'Investments',
              'Paying taxes',
            ],
            'answer': 'Everyday transactions',
          },
          {
            'question': 'What does ATM stand for?',
            'options': [
              'Auto Tech Machine',
              'Automated Teller Machine',
              'Advanced Time Money',
              'Auto Transaction Method',
            ],
            'answer': 'Automated Teller Machine',
          },
        ];
      default:
        return [];
    }
  }

  static IconData getIconForQuiz(String title) {
    switch (title) {
      case "Blockchain Basics":
        return Icons.account_balance_wallet;
      case "Fraud Awareness":
        return Icons.security;
      case "Banking Essentials":
        return Icons.account_balance;
      default:
        return Icons.help;
    }
  }
}
