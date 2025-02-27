import 'dart:convert';
import 'package:bakery_manager_mobile/models/account.dart';
import 'package:bakery_manager_mobile/models/ingredient.dart';
import 'package:bakery_manager_mobile/models/task.dart';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
//import '../models/account.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'session_manager.dart';

// API Service Class
class ApiService {
  static final baseApiUrl = dotenv.env['BASE_URL'];

  // Get Recipes Function
  static Future<Map<String, dynamic>> getRecipes() async {
    final url = Uri.parse('$baseApiUrl/recipes');
    final sessionToken = await SessionManager().getSessionToken();
    final headers = {'session_id': sessionToken!};
    try {
      final response = await http.get(url, headers: headers);

      // Successful response
      if (response.statusCode == 200) {
        Map<String, dynamic> body = json.decode(response.body);
        List<dynamic> recipeList = body['recipe'];
        return {
          'status': 'success',
          'recipes':
              recipeList.map((dynamic item) => Recipe.fromJson(item)).toList(),
        };
      }
      // Failed response
      else {
        return {
          'status': 'error',
          'reason': 'Failed to load recipes: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Network error
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  // Add Recipe Function
  static Future<Map<String, dynamic>> addRecipe(
      {String recipeName = "",
      String ingredients = "",
      int servings = 1,
      String description = "",
      String category = "",
      int prepTime = 0,
      int cookTime = 0}) async {
    final url = Uri.parse('$baseApiUrl/add_recipe');
    final sessionToken = await SessionManager().getSessionToken();
    final headers = {'Content-Type': 'application/json',
                     'session_id': sessionToken!
                    };
    final body = jsonEncode({
      "RecipeName": recipeName,
      "Instructions": ingredients,
      "Servings": servings.toString(),
      "Category": category,
      "PrepTime": prepTime,
      "CookTime": cookTime,
      "Description": description
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      // Successful response

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return {'status': 'success', 'recipeID': responseBody['recipeID']};
      }
      // Failed response
      else {
        return {
          'status': 'error',
          'reason': 'Failed to add recipe: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Network error
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateRecipe({
    required String recipeId,
    required String recipeName,
    required String instructions,
    required int servings,
    required String category,
    required int prepTime,
    required int cookTime,
    required String description,
  }) async {
    final url = Uri.parse('$baseApiUrl/update_recipe/$recipeId');
    final sessionToken = await SessionManager().getSessionToken();
    final headers = {'Content-Type': 'application/json',
                     'session_id': sessionToken!};
    final now = DateTime.now();
    final formattedDate =
        now.toIso8601String().split('T').join(' ').split('.').first;

    final body = jsonEncode({
      "RecipeName": recipeName,
      "Instructions": instructions,
      "Servings": servings.toString(),
      "Category": category,
      "PrepTime": prepTime,
      "CookTime": cookTime,
      "Description": description,
      "UpdatedAt": formattedDate,
    });

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'success',
          'updatedAt': responseBody['updatedAt'],
        };
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to update recipe: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteRecipe({
    required String recipeId,
  }) async {
    final url = Uri.parse('$baseApiUrl/delete_recipe/$recipeId');
    final sessionToken = await SessionManager().getSessionToken();
    final headers = {
      'Content-Type': 'application/json',
      'session_id': sessionToken!
    };

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'success',
          'message': responseBody['message'] ?? 'Recipe deleted successfully',
        };
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to delete recipe: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> addRecipeIngredient({
    required String recipeId,
    required String inventoryId,
    required double quantity,
    required String unitOfMeasure,
    double? scaleFactor,
    String? modifierId,
  }) async {
    final url = Uri.parse('$baseApiUrl/add_recipe_ingredient_full');
    final sessionId = await SessionManager().getSessionToken();

    final headers = <String, String>{
      'session_id': sessionId!,
      'recipe_id': recipeId,
      'inventory_id': inventoryId,
      'quantity': quantity.toString(),
      'unit_of_measure': unitOfMeasure,
    };

    if (scaleFactor != null) {
      headers['scale_factor'] = scaleFactor.toString();
    }

    if (modifierId != null) {
      headers['modifier_id'] = modifierId;
    }

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 201) {
        return {
          'status': 'success',
          'ingredient_id': jsonDecode(response.body)['ingredient_id']
        };
      } else {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'] ?? 'Failed to add recipe ingredient',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getRecipeIngredients(
      String recipeID) async {
    final url = Uri.parse('$baseApiUrl/recipe/$recipeID/ingredients');
    final sessionId = await SessionManager().getSessionToken();
    final headers = {
      'Content-Type': 'application/json',
      'session_id': sessionId!, // Include session ID in headers
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Ensure we access the correct structure of the response
        if (data['status'] == 'success') {
          // Extract the list of ingredients from the response
          final List ingredients = data['ingredients'];
          return {
            'status': 'success',
            'ingredients': ingredients,
          };
        } else {
          return {
            'status': 'error',
            'reason': data['reason'] ?? 'Unknown error',
          };
        }
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to fetch ingredients: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteIngredient(
      String ingredientId) async {
    final url = Uri.parse('$baseApiUrl/ingredient');
    String sessionId = await SessionManager().getSessionToken() ?? "";

    try {
      final response = await http.delete(
        url,
        headers: {
          'session_id': sessionId,
          'ingredient_id': ingredientId,
        },
      );

      if (response.statusCode == 200) {
        return {
          'status': 'success',
        };
      } else if (response.statusCode == 404) {
        return {
          'status': 'error',
          'reason': 'Ingredient not found in the database',
        };
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to delete ingredient: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateIngredient(
      String ingredientId,
      String inventoryId,
      double quantity,
      String unitOfMeasurement,
      String name) async {
    final url = Uri.parse('$baseApiUrl/ingredient');
    String sessionId = await SessionManager().getSessionToken() ?? "";

    try {
      final response = await http.put(
        url,
        headers: {
          'session_id': sessionId,
          'ingredient_id': ingredientId,
          'inventory_id': inventoryId,
          'quantity': quantity.toString(),
          'unit_of_measurement': unitOfMeasurement,
          'name': name,
        },
      );

      if (response.statusCode == 200) {
        return {
          'status': 'success',
        };
      } else {
        Map<String, dynamic> body = json.decode(response.body);
        return {
          'status': 'error',
          'reason': body['reason'] ??
              'Failed to update ingredient: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getInventory(
      {int page = 1, int pageSize = 20}) async {
    final url = Uri.parse('$baseApiUrl/inventory_amount');
    String sessionId = await SessionManager().getSessionToken() ?? "";
    try {
      final response = await http.get(
        url,
        headers: {
          'session_id': sessionId,
          'page': page.toString(),
          'page_size': pageSize.toString(),
        },
      );

      // Successful response
      if (response.statusCode == 200) {
        Map<String, dynamic> body = json.decode(response.body);
        List<dynamic> inventoryList = body['content'];
        return {
          'status': 'success',
          'inventory': inventoryList
              .map((dynamic item) => Ingredient.fromJson(item))
              .toList(),
          'page': body['page'],
          'page_count': body['page_count'],
        };
      }
      // Failed response
      else {
        return {
          'status': 'error',
          'reason': 'Failed to load inventory: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Network error
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> addInventoryItem({
    required String name,
    required double reorderAmount,
    required String reorderUnit,
    int? shelfLife,
    String? shelfLifeUnit,
  }) async {
    final url = Uri.parse('$baseApiUrl/inventory_item');
    final sessionId = await SessionManager().getSessionToken();
    final headers = <String, String>{
      'session_id': sessionId!,
      'name': name,
      'reorder_amount': reorderAmount.toString(),
      'reorder_unit': reorderUnit,
    };

    if (shelfLife != null) {
      headers['shelf_life'] = shelfLife.toString();
    }

    if (shelfLifeUnit != null) {
      headers['shelf_life_unit'] = shelfLifeUnit;
    }

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 201) {
        return {
          'status': 'success',
          'inventory_id': jsonDecode(response.body)['inventory_id']
        };
      } else {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'] ?? 'Failed to add inventory item',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> inventoryChange({
    required double changeAmount,
    required String inventoryId,
    String? description,
    String? expirationDate,
  }) async {
    final url = Uri.parse('$baseApiUrl/inventory_change');
    final sessionId = await SessionManager().getSessionToken();
    final headers = <String, String>{
      'session_id': sessionId!,
      'change_amount': changeAmount.toString(),
      'inventory_id': inventoryId,
    };

    // Add optional fields if they are provided
    if (description != null) {
      headers['description'] = description;
    }

    if (expirationDate != null) {
      headers['expiration_date'] = expirationDate;
    }

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 201) {
        return {
          'status': 'success',
          'hist_id': jsonDecode(response.body)['hist_id']
        };
      } else {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason':
              responseBody['reason'] ?? 'Failed to record inventory change',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> fetchIngredientHistory({
    required String inventoryId,
    int pageSize = 30,
  }) async {
    final url = Uri.parse('$baseApiUrl/inventory_change');
    final sessionId = await SessionManager().getSessionToken();

    if (sessionId == null) {
      return {
        'status': 'error',
        'reason': 'Missing session ID',
      };
    }

    final headers = <String, String>{
      'session_id': sessionId,
      'page_size': pageSize.toString(),
    };

    List<dynamic> allRecords = [];
    int page = 1;

    try {
      while (true) {
        // Update headers with the current page
        headers['page'] = page.toString();

        final response = await http.get(url, headers: headers);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['status'] == 'success') {
            final filteredContent =
                (data['content'] as List<dynamic>).where((item) {
              return item['InventoryID'] == inventoryId;
            }).toList();

            allRecords.addAll(filteredContent);

            // Check if we reached the last page
            if (page >= data['page_count']) {
              break; // No more pages to fetch
            }

            page++; // Go to the next page
          } else {
            return {
              'status': 'error',
              'reason': data['reason'] ?? 'Failed to fetch ingredient history',
            };
          }
        } else {
          final responseBody = jsonDecode(response.body);
          return {
            'status': 'error',
            'reason':
                responseBody['reason'] ?? 'Failed to fetch ingredient history',
          };
        }
      }

      return {
        'status': 'success',
        'page_count': page,
        'content': allRecords,
      };
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteInventoryHistory({
    required String histId,
  }) async {
    final url = Uri.parse('$baseApiUrl/inventory_change');
    final sessionId = await SessionManager().getSessionToken();

    if (sessionId == null) {
      return {
        'status': 'error',
        'reason': 'Missing session ID',
      };
    }

    final headers = <String, String>{
      'session_id': sessionId,
      'hist_id': histId,
    };

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': 'success',
          'content': data,
        };
      } else {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason':
              responseBody['reason'] ?? 'Failed to delete inventory history',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteInventoryItem({
    required String inventoryId,
  }) async {
    final url = Uri.parse('$baseApiUrl/inventory_item');
    final sessionId = await SessionManager().getSessionToken();

    if (sessionId == null) {
      return {
        'status': 'error',
        'reason': 'Missing session ID',
      };
    }

    final headers = <String, String>{
      'session_id': sessionId,
      'inventory_id': inventoryId,
    };

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': 'success',
          'content': data,
        };
      } else {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'] ?? 'Failed to delete inventory item',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateInventoryItem({
    required String inventoryId,
    required String name,
    required int? shelfLife,
    required String? shelfLifeUnit,
    required double reorderAmount,
    required String reorderUnit,
  }) async {
    final url = Uri.parse('$baseApiUrl/inventory_item');
    final sessionId = await SessionManager().getSessionToken();

    // Check if the session ID is available
    if (sessionId == null) {
      return {
        'status': 'error',
        'reason': 'Missing session ID',
      };
    }

    // Construct headers
    final headers = <String, String>{
      'session_id': sessionId,
      'inventory_id': inventoryId,
      'name': name,
      'reorder_amount': reorderAmount.toString(),
      'reorder_unit': reorderUnit,
    };

    // Add shelf life headers if provided
    if (shelfLife != null) {
      headers['shelf_life'] = shelfLife.toString();
    }
    if (shelfLifeUnit != null) {
      headers['shelf_life_unit'] = shelfLifeUnit;
    }

    try {
      // Send PUT request
      final response = await http.put(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': 'success',
          'inventory_id': data['inventory_id'],
        };
      } else {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'] ?? 'Failed to update inventory item',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  // Create Account Function
  static Future<Map<String, dynamic>> createAccount(
      String firstName,
      String lastName,
      String employeeID,
      String username,
      String password,
      String email,
      String phoneNumber) async {
    final url = Uri.parse('$baseApiUrl/create_account');
    final headers = {
      'employee_id': employeeID,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'password': password,
      'email_address': email,
      'phone_number': phoneNumber
    };

    try {
      final response = await http.post(url, headers: headers);

      // Successful response
      if (response.statusCode == 201) {
        return {'status': 'success'};
      }
      // Failed response
      else {
        return {
          'status': 'error',
          'reason': 'Failed to create account: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Network error
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getTasks() async {
    final url = Uri.parse('$baseApiUrl/tasks');
    String sessionId = await SessionManager().getSessionToken() ?? "";

    try {
      final response = await http.get(
        url,
        headers: {
          'session_id': sessionId,
        },
      );

      // Successful response
      if (response.statusCode == 200) {
        Map<String, dynamic> body = json.decode(response.body);
        List<dynamic> taskList = body['recipes']; // Assuming 'tasks' as key
        return {
          'status': 'success',
          'tasks': taskList.map((dynamic item) => Task.fromJson(item)).toList(),
        };
      }
      // Failed response
      else {
        return {
          'status': 'error',
          'reason': 'Failed to load tasks: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> addTask({
    required String recipeID,
    required int amountToBake,
    required String assignedEmployeeID,
    required String dueDate,
    String? comments,
  }) async {
    final url = Uri.parse('$baseApiUrl/add_task');
    final sessionId = await SessionManager()
        .getSessionToken(); // Assuming session manager gives you session token

    // Set headers, including session_id
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'session_id': sessionId!,
    };

    // Prepare the request body
    final Map<String, dynamic> body = {
      'RecipeID': recipeID,
      'AmountToBake': amountToBake,
      'AssignedEmployeeID': assignedEmployeeID,
      'DueDate': dueDate,
    };

    // Add comments if provided
    if (comments != null && comments.isNotEmpty) {
      body['Comments'] = comments;
    }

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        // Success response, parse response if needed
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'success',
          'taskID': responseBody['taskID'],
          if (responseBody['commentID'] != null)
            'commentID': responseBody['commentID'],
        };
      } else {
        // Handle error responses
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'] ?? 'Failed to add task',
        };
      }
    } catch (e) {
      // Handle network or parsing errors
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteTask(String taskID) async {
    final url = Uri.parse('$baseApiUrl/delete_task/$taskID');
    final sessionId = await SessionManager().getSessionToken();

    // Set headers including session_id
    final headers = <String, String>{
      'session_id': sessionId!,
    };

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        return {'status': 'success'};
      } else if (response.statusCode == 403) {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'] ?? 'Forbidden access',
        };
      } else if (response.statusCode == 500) {
        final response = await http.delete(url, headers: headers);
        if (response.statusCode == 200) {
          return {'status': 'success'};
        } else if (response.statusCode == 403) {
          final responseBody = jsonDecode(response.body);
          return {
            'status': 'error',
            'reason': responseBody['reason'] ?? 'Forbidden access',
          };
        } else {
          return {
            'status': 'error',
            'reason': 'Failed to delete task: ${response.statusCode}',
          };
        }
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to delete task: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateTask({
    required String taskID,
    required String recipeID,
    required int amountToBake,
    required String assignedEmployeeID,
    String? comments,
    String? commentID,
    required String dueDate,
    required String status,
  }) async {
    final url = Uri.parse('$baseApiUrl/update_task/$taskID');
    final sessionId = await SessionManager().getSessionToken();

    // Set headers including session_id
    final headers = <String, String>{
      'session_id': sessionId!,
      'Content-Type': 'application/json', // Specify that we are sending JSON
    };

    // Prepare the body for the request
    final body = jsonEncode({
      'RecipeID': recipeID,
      'AmountToBake': amountToBake,
      'AssignedEmployeeID': assignedEmployeeID,
      'DueDate': dueDate,
      'Status': status,
    });

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return {'status': 'success'};
      } else if (response.statusCode == 400) {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'] ?? 'Bad request',
        };
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to update task: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> completeTask({
    required String taskID,
    required String taskStatus,
  }) async {
    final url = Uri.parse('$baseApiUrl/task_complete');
    final sessionId =
        await SessionManager().getSessionToken(); // Fetch session token

    // Set headers, including session_id and task_id
    final headers = <String, String>{
      'session_id': sessionId!,
      'task_id': taskID,
      'task_status': taskStatus
    };

    try {
      // Send POST request to complete task
      final response = await http.post(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        // If the request is successful, parse the response
        final responseBody = jsonDecode(response.body);
        return {
          'status': responseBody['status'],
        };
      } else {
        // Handle error responses
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'] ?? 'Failed to complete task',
        };
      }
    } catch (e) {
      // Handle network or parsing errors
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> addUserEmail({
    required String emailAddress,
    required String type,
  }) async {
    final url = Uri.parse('$baseApiUrl/add_user_email');
    final sessionId = await SessionManager().getSessionToken();
    final headers = <String, String>{
      'session_id': sessionId!,
      'email_address': emailAddress,
      'type': type
    };

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 201) {
        return {'status': 'success'};
      } else {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'] ?? 'Failed to add email',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteUserEmail({
    required String emailAddress,
  }) async {
    final url = Uri.parse('$baseApiUrl/user_email');
    final sessionId = await SessionManager().getSessionToken();
    final headers = <String, String>{
      'session_id': sessionId!,
      'email_address': emailAddress
    };

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        return {'status': 'success'};
      } else if (response.statusCode == 409) {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'] ?? 'Email address does not exist',
        };
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to delete email: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> addUserPhone({
    required String phoneNumber,
    required String type,
  }) async {
    final url = Uri.parse('$baseApiUrl/add_user_phone');
    final sessionId = await SessionManager().getSessionToken();
    final headers = <String, String>{
      'session_id': sessionId!,
      'phone_number': phoneNumber,
      'type': type,
    };

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 201) {
        return {'status': 'success'};
      } else {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'] ?? 'Failed to add phone number',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteUserPhone({
    required String phoneNumber,
  }) async {
    final url = Uri.parse('$baseApiUrl/user_phone');
    final sessionId = await SessionManager().getSessionToken();
    final headers = <String, String>{
      'session_id': sessionId!,
      'phone_number': phoneNumber,
    };

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        return {'status': 'success'};
      } else if (response.statusCode == 409) {
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'] ?? 'Phone number does not exist',
        };
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to delete phone number: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  // Login Function
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final url = Uri.parse('$baseApiUrl/login');
    final headers = <String, String>{
      'username': username,
      'password': password,
    };
    try {
      final response = await http.post(url, headers: headers);

      // Successful response
      if (response.statusCode == 201) {
        // Successfully logged in
        final responseBody = jsonDecode(response.body);
        final sessionManager = SessionManager();
        sessionManager.saveSession(responseBody['session_id']);
        //sessionManager.resetIdleTimer();
        return {
          'status': 'success',
        };
      }
      // Failed response
      else if (response.statusCode == 400 || response.statusCode == 401) {
        // Handle client errors
        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'reason': responseBody['reason'],
        };
      }
      // Failed response
      else {
        // Handle server errors
        return {
          'status': 'error',
          'reason': 'Unexpected error: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Handle network errors
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<bool> sessionValidate(sessionID) async {
    final url = Uri.parse('$baseApiUrl/token_bump');
    final headers = <String, String>{
      'session_id': sessionID,
    };
    try {
      final response = await http.post(url, headers: headers);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> logout() async {
    final url = Uri.parse('$baseApiUrl/logout');
    final sessionManager = SessionManager();
    final sessionID = await sessionManager.getSessionToken();
    try {
      final headers = <String, String>{
        'session_id': sessionID!,
      };

      final response = await http.post(url, headers: headers);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Get Account Function
  static Future<Map<String, dynamic>> getUserInfo() async {
    final url = Uri.parse('$baseApiUrl/my_info');
    String sessionId = await SessionManager().getSessionToken() ?? "";

    try {
      // Make the HTTP GET request
      final response = await http.get(
        url,
        headers: {
          'session_id': sessionId,
        },
      );

      // Successful response
      if (response.statusCode == 200) {
        Map<String, dynamic> body = json.decode(response.body);

        if (body['status'] == 'success') {
          return {
            'status': 'success',
            'content': body['content'], // Includes all user information
          };
        } else {
          return {
            'status': 'error',
            'reason': body['reason'],
          };
        }
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to load user info: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getUserList(
      {int page = 1, int pageSize = 20}) async {
    final url = Uri.parse('$baseApiUrl/user_list');
    String sessionId = await SessionManager().getSessionToken() ?? "";

    try {
      // Make the HTTP GET request
      final response = await http.get(
        url,
        headers: {
          'session_id': sessionId,
          'page': page.toString(),
          'page_size': pageSize.toString(),
        },
      );

      // Successful response
      if (response.statusCode == 200) {
        Map<String, dynamic> body = json.decode(response.body);

        if (body['status'] == 'success') {
          return {
            'status': 'success',
            'page': body['page'],
            'page_count': body['page_count'],
            'content': (body['content'] as List<dynamic>)
                .map((user) => Account.fromJson(user))
                .toList(), // Includes list of users
          };
        } else {
          return {
            'status': 'error',
            'reason': body['reason'],
          };
        }
      } else {
        return {
          'status': 'error',
          'reason': 'Failed to load user list: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'reason': 'Network error: $e',
      };
    }
  }
}
