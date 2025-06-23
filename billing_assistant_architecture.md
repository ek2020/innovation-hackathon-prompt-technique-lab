# Billing Assistant Architecture

This document outlines the architectural design for implementing the AI-powered billing support assistant for a SaaS product.

## System Architecture Overview

```
┌─────────────────────────────────────┐
│                                     │
│            Customer User            │
│                                     │
└───────────────────┬─────────────────┘
                    │
                    ▼
┌─────────────────────────────────────┐
│                                     │
│           Frontend Interface        │
│                                     │
└───────────────────┬─────────────────┘
                    │
                    ▼
┌─────────────────────────────────────┐
│                                     │
│         Query Processing Layer      │
│                                     │
└───────────────────┬─────────────────┘
                    │
                    ▼
┌─────────────────────────────────────┐
│                                     │
│        Prompt Assembly Engine       │
│                                     │
└───────────────────┬─────────────────┘
                    │
                    ▼
┌─────────────────────────────────────┐
│                                     │
│           LLM Integration           │
│                                     │
└───────────────────┬─────────────────┘
                    │
                    ▼
┌─────────────────────────────────────┐
│                                     │
│       Response Processing Layer     │
│                                     │
└───────────────────┬─────────────────┘
                    │
                    ▼
┌─────────────────────────────────────┐
│                                     │
│           Response to User          │
│                                     │
└─────────────────────────────────────┘
```

## Component Breakdown

### 1. Frontend Interface

The customer-facing interface where users can submit billing questions and receive responses.

**Key Features:**
- Chat-like interface for natural conversation
- Support for message history and context retention
- Ability to upload relevant documents (invoices, receipts)
- Mobile-responsive design

**Technologies:**
- React/Vue.js for frontend framework
- WebSockets for real-time communication
- Markdown rendering for formatted responses

### 2. Query Processing Layer

Processes incoming customer queries before they are sent to the prompt assembly engine.

**Key Functions:**
- Query classification (identifying query type)
- Entity extraction (plan names, dates, amounts)
- Context enrichment (adding user account information)
- Query reformulation for clarity

**Technologies:**
- NLP preprocessing libraries
- Custom classification models
- Entity recognition systems

### 3. Prompt Assembly Engine

Constructs the appropriate prompt to send to the LLM based on the query type and available context.

**Key Functions:**
- Dynamic prompt template selection
- Context insertion into templates
- Prompt optimization for token efficiency
- Version control for prompts

**Implementation:**
- Template management system
- Context prioritization algorithms
- A/B testing framework for prompt variations

### 4. LLM Integration

Handles communication with the Large Language Model service.

**Key Functions:**
- API communication with LLM provider
- Parameter management (temperature, top_p, etc.)
- Response streaming
- Error handling and retry logic

**Technologies:**
- OpenAI API / Azure OpenAI / Anthropic Claude
- Caching layer for common queries
- Fallback mechanisms for service disruptions

### 5. Response Processing Layer

Processes the raw LLM response before presenting it to the user.

**Key Functions:**
- Response validation (policy compliance check)
- Formatting and structure enforcement
- Adding relevant links and resources
- Personalization based on user context

**Technologies:**
- Content validation rules engine
- Markdown/HTML formatter
- Link enrichment service

## Prompt Architecture

### Layered Prompt Design

The prompt is structured in distinct layers with clear boundaries:

```
┌─────────────────────────────────────────────────┐
│                                                 │
│               CONTEXT LAYER                     │
│  (Product info, pricing, policies)              │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│               CONSTRAINTS LAYER                 │
│    (Boundaries and limitations)                 │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│             REASONING PROCESS LAYER             │
│     (Step-by-step analysis instructions)        │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│             RESPONSE STRUCTURE LAYER            │
│     (Format and content requirements)           │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│                  USER QUERY                     │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Dynamic Prompt Selection

The system selects the appropriate prompt template based on query classification:

1. **Standard Billing Query**: Uses the refined prompt
2. **Complex Calculation Query**: Uses the CoT-enhanced prompt
3. **Account-Specific Query**: Uses a specialized prompt with account context
4. **Technical Issue Query**: Uses a troubleshooting-focused prompt

## Data Flow Architecture

```
┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│               │     │               │     │               │
│  User Account ├────►│ Billing Data  ├────►│ Policy Store  │
│               │     │               │     │               │
└───────────────┘     └───────┬───────┘     └───────────────┘
                            │
                            ▼
┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│               │     │               │     │               │
│  User Query   ├────►│ Prompt Engine ├────►│    LLM API    │
│               │     │               │     │               │
└───────────────┘     └───────────────┘     └───────┬───────┘
                                                   │
┌───────────────┐     ┌───────────────┐            │
│               │     │               │            │
│  UI Renderer  │◄────┤Response Handler◄────────────
│               │     │               │
└───────────────┘     └───────────────┘
```

## Implementation Strategy

### 1. Prompt Management System

A dedicated system for managing, versioning, and optimizing prompts:

```javascript
// prompt-manager.js
class PromptManager {
  constructor(templateStore, contextService) {
    this.templateStore = templateStore;
    this.contextService = contextService;
    this.activeVersions = {
      standard: 'v1.2',
      cot: 'v1.0',
      account: 'v1.1',
      technical: 'v1.0'
    };
  }
  
  async getPromptForQuery(queryType, userId, queryText) {
    // Get the appropriate template version
    const templateVersion = this.activeVersions[queryType] || this.activeVersions.standard;
    const template = await this.templateStore.getTemplate(queryType, templateVersion);
    
    // Get relevant context
    const context = await this.contextService.getContextForUser(userId);
    
    // Assemble the prompt
    return this._assemblePrompt(template, context, queryText);
  }
  
  _assemblePrompt(template, context, queryText) {
    // Replace template variables with context values
    let prompt = template;
    
    // Insert product information
    prompt = prompt.replace('{{product_name}}', context.productName);
    
    // Insert pricing information
    const pricingInfo = this._formatPricingInfo(context.plans);
    prompt = prompt.replace('{{pricing_info}}', pricingInfo);
    
    // Insert policies
    prompt = prompt.replace('{{refund_policy}}', context.policies.refund);
    prompt = prompt.replace('{{payment_policy}}', context.policies.payment);
    
    // Add the user query
    prompt = prompt.replace('{{user_query}}', queryText);
    
    return prompt;
  }
  
  _formatPricingInfo(plans) {
    return plans.map(plan => 
      `${plan.name} ($${plan.monthlyPrice}/month or $${plan.annualPrice}/year)`
    ).join(', ');
  }
}
```

### 2. Query Classification System

A system to determine the appropriate prompt type based on query analysis:

```javascript
// query-classifier.js
class QueryClassifier {
  constructor() {
    this.patterns = {
      refund: [/refund/i, /money back/i, /cancel.*subscription/i],
      charge: [/charge/i, /bill/i, /payment/i, /\$\d+/],
      calculation: [/how much/i, /calculate/i, /prorate/i, /difference/i],
      technical: [/error/i, /can't access/i, /problem/i, /doesn't work/i]
    };
  }
  
  classifyQuery(queryText) {
    // Check for calculation indicators (complex queries that benefit from CoT)
    const hasCalculationElements = this._matchesPatterns(queryText, this.patterns.calculation);
    const hasChargeDiscussion = this._matchesPatterns(queryText, this.patterns.charge);
    const hasRefundRequest = this._matchesPatterns(queryText, this.patterns.refund);
    const hasTechnicalIssue = this._matchesPatterns(queryText, this.patterns.technical);
    
    // Determine the appropriate prompt type
    if ((hasCalculationElements && hasChargeDiscussion) || 
        (hasCalculationElements && hasRefundRequest)) {
      return 'cot'; // Use Chain-of-Thought for complex calculations
    } else if (hasTechnicalIssue) {
      return 'technical';
    } else if (queryText.includes('my account') || queryText.includes('my subscription')) {
      return 'account';
    } else {
      return 'standard';
    }
  }
  
  _matchesPatterns(text, patterns) {
    return patterns.some(pattern => pattern.test(text));
  }
}
```

### 3. Response Processing System

A system to process and enhance LLM responses:

```javascript
// response-processor.js
class ResponseProcessor {
  constructor(linkEnricher, policyValidator) {
    this.linkEnricher = linkEnricher;
    this.policyValidator = policyValidator;
  }
  
  async processResponse(rawResponse, queryType) {
    // Validate the response against policies
    const validationResult = this.policyValidator.validate(rawResponse);
    if (!validationResult.valid) {
      // Log the issue and apply corrections if possible
      console.warn('Policy validation failed:', validationResult.issues);
      rawResponse = this._applyPolicyCorrections(rawResponse, validationResult);
    }
    
    // Format the response based on query type
    let formattedResponse = rawResponse;
    
    if (queryType === 'cot') {
      // Ensure the analysis section is properly formatted
      formattedResponse = this._formatAnalysisSection(formattedResponse);
    }
    
    // Enrich with relevant links
    formattedResponse = await this.linkEnricher.addLinks(formattedResponse);
    
    return formattedResponse;
  }
  
  _formatAnalysisSection(response) {
    // Ensure "My Analysis:" is properly formatted as a heading
    return response.replace(
      /My Analysis:/g, 
      '\n\n**My Analysis:**\n'
    );
  }
  
  _applyPolicyCorrections(response, validationResult) {
    let corrected = response;
    
    // Apply corrections for common policy misstatements
    validationResult.issues.forEach(issue => {
      corrected = corrected.replace(issue.problematicText, issue.correctedText);
    });
    
    return corrected;
  }
}
```

## Integration with Existing Systems

### 1. Billing System Integration

```javascript
// billing-integration.js
class BillingSystemIntegration {
  constructor(billingApiClient) {
    this.billingApiClient = billingApiClient;
  }
  
  async getCustomerBillingContext(customerId) {
    // Get customer subscription details
    const subscription = await this.billingApiClient.getSubscription(customerId);
    
    // Get recent invoices
    const invoices = await this.billingApiClient.getRecentInvoices(customerId, 3);
    
    // Get payment methods
    const paymentMethods = await this.billingApiClient.getPaymentMethods(customerId);
    
    // Format the data for the prompt context
    return {
      currentPlan: subscription.planName,
      billingCycle: subscription.billingCycle,
      nextBillingDate: subscription.nextBillingDate,
      paymentMethodType: paymentMethods[0]?.type || 'None',
      recentCharges: invoices.map(invoice => ({
        date: invoice.date,
        amount: invoice.amount,
        status: invoice.status,
        items: invoice.lineItems.map(item => ({
          description: item.description,
          amount: item.amount
        }))
      }))
    };
  }
}
```

### 2. User Authentication Integration

```javascript
// auth-integration.js
class AuthIntegration {
  constructor(authService) {
    this.authService = authService;
  }
  
  async validateUserAccess(userId, sessionToken) {
    // Verify the user's session is valid
    const sessionValid = await this.authService.validateSession(userId, sessionToken);
    
    if (!sessionValid) {
      throw new Error('Unauthorized access');
    }
    
    // Get the user's permissions
    const permissions = await this.authService.getUserPermissions(userId);
    
    // Check if user has access to billing support
    if (!permissions.includes('billing_support')) {
      throw new Error('User does not have access to billing support');
    }
    
    return {
      userId,
      permissions,
      authenticated: true
    };
  }
}
```

## Monitoring and Analytics

### 1. Prompt Performance Tracking

```javascript
// prompt-analytics.js
class PromptAnalytics {
  constructor(analyticsStore) {
    this.analyticsStore = analyticsStore;
  }
  
  async trackPromptPerformance(promptData) {
    const {
      promptId,
      promptVersion,
      queryType,
      tokenCount,
      responseTime,
      userFeedback,
      followupQueries
    } = promptData;
    
    // Store the performance data
    await this.analyticsStore.recordPromptUse({
      promptId,
      promptVersion,
      queryType,
      tokenCount,
      responseTime,
      timestamp: new Date(),
      userFeedback,
      followupQueries: followupQueries || 0
    });
    
    // Update aggregate metrics
    await this.updateAggregateMetrics(promptId, promptVersion, userFeedback);
  }
  
  async updateAggregateMetrics(promptId, promptVersion, userFeedback) {
    // Get current metrics
    const metrics = await this.analyticsStore.getPromptMetrics(promptId, promptVersion);
    
    // Update metrics based on feedback
    const updatedMetrics = {
      useCount: metrics.useCount + 1,
      averageResponseTime: this._updateAverage(
        metrics.averageResponseTime,
        metrics.useCount,
        userFeedback.responseTime
      ),
      satisfactionScore: this._updateAverage(
        metrics.satisfactionScore,
        metrics.useCount,
        userFeedback.satisfaction
      ),
      resolutionRate: this._updateAverage(
        metrics.resolutionRate,
        metrics.useCount,
        userFeedback.resolved ? 1 : 0
      )
    };
    
    // Store updated metrics
    await this.analyticsStore.updatePromptMetrics(promptId, promptVersion, updatedMetrics);
  }
  
  _updateAverage(currentAvg, count, newValue) {
    return (currentAvg * count + newValue) / (count + 1);
  }
}
```

### 2. User Interaction Analytics

```javascript
// interaction-analytics.js
class InteractionAnalytics {
  constructor(analyticsStore) {
    this.analyticsStore = analyticsStore;
  }
  
  async trackConversation(conversationData) {
    const {
      conversationId,
      userId,
      queryCount,
      duration,
      queryTypes,
      resolutionStatus,
      feedbackScore
    } = conversationData;
    
    // Record the conversation data
    await this.analyticsStore.recordConversation({
      conversationId,
      userId,
      queryCount,
      duration,
      queryTypes,
      resolutionStatus,
      feedbackScore,
      timestamp: new Date()
    });
    
    // Update user metrics
    await this.updateUserMetrics(userId, {
      conversationCount: 1,
      totalQueries: queryCount,
      averageFeedback: feedbackScore,
      resolved: resolutionStatus === 'resolved'
    });
  }
  
  async updateUserMetrics(userId, interactionData) {
    // Get current user metrics
    const metrics = await this.analyticsStore.getUserMetrics(userId);
    
    // Update metrics
    const updatedMetrics = {
      conversationCount: metrics.conversationCount + 1,
      totalQueries: metrics.totalQueries + interactionData.totalQueries,
      averageFeedback: this._updateAverage(
        metrics.averageFeedback,
        metrics.conversationCount,
        interactionData.averageFeedback
      ),
      resolutionRate: this._updateAverage(
        metrics.resolutionRate,
        metrics.conversationCount,
        interactionData.resolved ? 1 : 0
      )
    };
    
    // Store updated metrics
    await this.analyticsStore.updateUserMetrics(userId, updatedMetrics);
  }
  
  _updateAverage(currentAvg, count, newValue) {
    return (currentAvg * count + newValue) / (count + 1);
  }
}
```

## Deployment Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│                        Load Balancer                                │
│                                                                     │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                ┌───────────────┼───────────────┐
                │               │               │
                ▼               ▼               ▼
┌───────────────────┐ ┌───────────────────┐ ┌───────────────────┐
│                   │ │                   │ │                   │
│  Web Server 1     │ │  Web Server 2     │ │  Web Server 3     │
│                   │ │                   │ │                   │
└─────────┬─────────┘ └─────────┬─────────┘ └─────────┬─────────┘
          │                     │                     │
          └─────────────────────┼─────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│                     Application Services                            │
│                                                                     │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐      │
│  │                 │  │                 │  │                 │      │
│  │ Prompt Service  │  │ Billing Service │  │ Analytics       │      │
│  │                 │  │                 │  │                 │      │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘      │
│                                                                     │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│                        Data Layer                                   │
│                                                                     │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐      │
│  │                 │  │                 │  │                 │      │
│  │ Prompt DB       │  │ User DB         │  │ Analytics DB    │      │
│  │                 │  │                 │  │                 │      │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Conclusion

This architecture provides a comprehensive framework for implementing the billing support assistant with both the refined prompt and Chain-of-Thought enhanced prompt capabilities. The system is designed to:

1. Dynamically select the appropriate prompt based on query complexity
2. Integrate with existing billing and authentication systems
3. Process and enhance LLM responses for consistency and accuracy
4. Track performance metrics to continuously improve prompt effectiveness

The modular design allows for easy updates to prompt templates and integration with different LLM providers as needed.
