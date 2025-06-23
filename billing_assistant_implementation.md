# Billing Assistant Implementation Guide

This document provides practical implementation examples for the AI-powered billing support assistant, including code samples for both the refined prompt and Chain-of-Thought enhanced versions.

## Frontend Implementation

### React Component for Billing Assistant Chat

```jsx
// BillingAssistantChat.jsx
import React, { useState, useEffect, useRef } from 'react';
import './BillingAssistantChat.css';
import { sendQuery } from '../services/billingAssistantService';

const BillingAssistantChat = ({ userId, sessionToken }) => {
  const [messages, setMessages] = useState([
    { 
      role: 'assistant', 
      content: 'Hello! I\'m your billing assistant. How can I help you with your billing questions today?' 
    }
  ]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);
  const messagesEndRef = useRef(null);

  // Auto-scroll to bottom of messages
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleInputChange = (e) => {
    setInput(e.target.value);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!input.trim()) return;
    
    // Add user message to chat
    const userMessage = input.trim();
    setMessages(prev => [...prev, { role: 'user', content: userMessage }]);
    setInput('');
    setIsLoading(true);
    setError(null);
    
    try {
      // Send query to backend
      const response = await sendQuery({
        userId,
        sessionToken,
        query: userMessage,
        conversationHistory: messages.map(msg => ({
          role: msg.role,
          content: msg.content
        }))
      });
      
      // Add assistant response to chat
      setMessages(prev => [...prev, { 
        role: 'assistant', 
        content: response.message,
        analysis: response.analysis,
        links: response.links,
        warning: response.warning
      }]);
      
    } catch (err) {
      console.error('Error querying billing assistant:', err);
      setError('Sorry, there was an error processing your request. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  // Render a message with optional analysis section
  const renderMessage = (message, index) => {
    return (
      <div key={index} className={`message ${message.role}`}>
        <div className="message-content">
          {message.role === 'assistant' && message.analysis ? (
            <>
              {/* Split content to extract parts before and after analysis if needed */}
              {message.content.split('My Analysis:')[0]}
              
              <div className="analysis-section">
                <h4>My Analysis:</h4>
                <ol>
                  {message.analysis.steps.map((step, i) => (
                    <li key={i}>{step}</li>
                  ))}
                </ol>
              </div>
              
              {/* Show the rest of the content after analysis */}
              {message.content.includes('My Analysis:') && 
                message.content.split('My Analysis:')[1].split('\n').slice(message.analysis.steps.length + 1).join('\n')}
            </>
          ) : (
            message.content
          )}
          
          {message.links && message.links.length > 0 && (
            <div className="helpful-links">
              <h4>Helpful Resources:</h4>
              <ul>
                {message.links.map((link, i) => (
                  <li key={i}>
                    <a href={link.url} target="_blank" rel="noopener noreferrer">
                      {link.title}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
          )}
          
          {message.warning && (
            <div className="message-warning">
              <i className="warning-icon">⚠️</i> {message.warning}
            </div>
          )}
        </div>
      </div>
    );
  };

  return (
    <div className="billing-assistant-container">
      <div className="billing-assistant-header">
        <h2>Billing Support Assistant</h2>
      </div>
      
      <div className="billing-assistant-messages">
        {messages.map((msg, index) => renderMessage(msg, index))}
        
        {isLoading && (
          <div className="message assistant loading">
            <div className="typing-indicator">
              <span></span>
              <span></span>
              <span></span>
            </div>
          </div>
        )}
        
        {error && (
          <div className="message error">
            <div className="message-content">{error}</div>
          </div>
        )}
        
        <div ref={messagesEndRef} />
      </div>
      
      <form className="billing-assistant-input" onSubmit={handleSubmit}>
        <input
          type="text"
          value={input}
          onChange={handleInputChange}
          placeholder="Ask about billing, payments, refunds, etc."
          disabled={isLoading}
        />
        <button type="submit" disabled={isLoading || !input.trim()}>
          {isLoading ? 'Sending...' : 'Send'}
        </button>
      </form>
      
      <div className="billing-assistant-footer">
        <p>For urgent matters, please contact billing@company.com</p>
      </div>
    </div>
  );
};

export default BillingAssistantChat;
```

### CSS Styling

```css
/* BillingAssistantChat.css */
.billing-assistant-container {
  display: flex;
  flex-direction: column;
  height: 600px;
  max-width: 800px;
  margin: 0 auto;
  border: 1px solid #ddd;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  background-color: #f9f9f9;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
}

.billing-assistant-header {
  padding: 15px 20px;
  background-color: #0056b3;
  color: white;
}

.billing-assistant-header h2 {
  margin: 0;
  font-size: 18px;
}

.billing-assistant-messages {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.message {
  max-width: 80%;
  padding: 12px 16px;
  border-radius: 18px;
  line-height: 1.4;
}

.message.user {
  align-self: flex-end;
  background-color: #0084ff;
  color: white;
  border-bottom-right-radius: 4px;
}

.message.assistant {
  align-self: flex-start;
  background-color: #e5e5ea;
  color: #333;
  border-bottom-left-radius: 4px;
}

.message.error {
  align-self: center;
  background-color: #ffdddd;
  color: #d32f2f;
  border-radius: 8px;
  text-align: center;
  width: 90%;
}

.analysis-section {
  background-color: #f0f7ff;
  border-left: 3px solid #0056b3;
  padding: 10px 15px;
  margin: 15px 0;
  border-radius: 4px;
}

.analysis-section h4 {
  margin-top: 0;
  color: #0056b3;
}

.analysis-section ol {
  margin-bottom: 0;
  padding-left: 20px;
}

.helpful-links {
  margin-top: 15px;
  padding-top: 10px;
  border-top: 1px solid #ddd;
}

.helpful-links h4 {
  margin-top: 0;
  font-size: 14px;
  color: #555;
}

.helpful-links ul {
  padding-left: 20px;
  margin-bottom: 0;
}

.helpful-links a {
  color: #0056b3;
  text-decoration: none;
}

.helpful-links a:hover {
  text-decoration: underline;
}

.message-warning {
  margin-top: 8px;
  padding: 6px 10px;
  background-color: #fff3cd;
  border-left: 4px solid #ffc107;
  color: #856404;
  font-size: 0.9em;
  border-radius: 4px;
}

.warning-icon {
  margin-right: 6px;
}

.typing-indicator {
  display: flex;
  align-items: center;
  gap: 5px;
}

.typing-indicator span {
  width: 8px;
  height: 8px;
  background-color: #999;
  border-radius: 50%;
  display: inline-block;
  animation: bounce 1.4s infinite ease-in-out both;
}

.typing-indicator span:nth-child(1) {
  animation-delay: -0.32s;
}

.typing-indicator span:nth-child(2) {
  animation-delay: -0.16s;
}

@keyframes bounce {
  0%, 80%, 100% { transform: scale(0); }
  40% { transform: scale(1); }
}

.billing-assistant-input {
  display: flex;
  padding: 15px;
  background-color: white;
  border-top: 1px solid #ddd;
}

.billing-assistant-input input {
  flex: 1;
  padding: 12px 15px;
  border: 1px solid #ddd;
  border-radius: 20px;
  font-size: 14px;
  outline: none;
}

.billing-assistant-input input:focus {
  border-color: #0056b3;
}

.billing-assistant-input button {
  margin-left: 10px;
  padding: 0 20px;
  background-color: #0056b3;
  color: white;
  border: none;
  border-radius: 20px;
  cursor: pointer;
  font-weight: bold;
  transition: background-color 0.2s;
}

.billing-assistant-input button:hover {
  background-color: #003d82;
}

.billing-assistant-input button:disabled {
  background-color: #cccccc;
  cursor: not-allowed;
}

.billing-assistant-footer {
  padding: 10px 15px;
  background-color: #f0f0f0;
  border-top: 1px solid #ddd;
  font-size: 12px;
  color: #666;
  text-align: center;
}
```

## Backend Implementation

### Express API Endpoint

```javascript
// billing-assistant-api.js
const express = require('express');
const router = express.Router();
const QueryClassifier = require('../services/query-classifier');
const PromptManager = require('../services/prompt-manager');
const LLMService = require('../services/llm-service');
const ResponseProcessor = require('../services/response-processor');
const BillingSystemIntegration = require('../integrations/billing-integration');
const AnalyticsService = require('../services/analytics-service');

// Initialize services
const queryClassifier = new QueryClassifier();
const promptManager = new PromptManager(
  require('../stores/template-store'),
  require('../services/context-service')
);
const llmService = new LLMService();
const responseProcessor = new ResponseProcessor(
  require('../services/link-enricher'),
  require('../services/policy-validator')
);
const billingIntegration = new BillingSystemIntegration(
  require('../clients/billing-api-client')
);
const analyticsService = new AnalyticsService();

// Middleware for authentication
const authenticateUser = require('../middleware/authenticate');

// Billing Assistant endpoint
router.post('/query', authenticateUser, async (req, res) => {
  try {
    const { userId, query, conversationHistory } = req.body;
    const startTime = Date.now();
    
    // Step 1: Classify the query to determine prompt type
    const queryType = queryClassifier.classifyQuery(query);
    
    // Step 2: Get billing context for the user
    const billingContext = await billingIntegration.getCustomerBillingContext(userId);
    
    // Step 3: Get the appropriate prompt
    const prompt = await promptManager.getPromptForQuery(
      queryType, 
      userId, 
      query,
      billingContext,
      conversationHistory
    );
    
    // Step 4: Send to LLM
    const llmResponse = await llmService.generateResponse(prompt);
    
    // Step 5: Process the response
    const processedResponse = await responseProcessor.processResponse(
      llmResponse, 
      queryType,
      billingContext
    );
    
    // Step 6: Extract analysis section if present (for CoT responses)
    const { message, analysis, links } = extractResponseComponents(processedResponse, queryType);
    
    // Step 7: Log analytics
    await analyticsService.trackInteraction({
      userId,
      queryType,
      query,
      responseTime: Date.now() - startTime,
      promptTokens: llmService.lastPromptTokens,
      responseTokens: llmService.lastResponseTokens
    });
    
    // Step 8: Return response
    return res.json({
      message,
      analysis,
      links,
      queryType
    });
    
  } catch (error) {
    console.error('Error in billing assistant:', error);
    return res.status(500).json({ error: 'An error occurred processing your request' });
  }
});

// Helper function to extract components from response
function extractResponseComponents(response, queryType) {
  // For CoT responses, extract the analysis section
  if (queryType === 'cot' && response.includes('My Analysis:')) {
    const parts = response.split('My Analysis:');
    const beforeAnalysis = parts[0];
    
    // Extract the analysis steps
    const analysisAndRest = parts[1];
    const analysisLines = analysisAndRest.split('\n').filter(line => line.trim());
    
    // Find where the numbered list ends
    let analysisEndIndex = 0;
    for (let i = 0; i < analysisLines.length; i++) {
      if (!analysisLines[i].match(/^\d+\.\s/) && analysisEndIndex === 0) {
        analysisEndIndex = i;
        break;
      }
    }
    
    // If we couldn't find the end, assume it's the whole thing
    if (analysisEndIndex === 0) {
      analysisEndIndex = analysisLines.length;
    }
    
    const analysisSteps = analysisLines.slice(0, analysisEndIndex)
      .map(line => line.replace(/^\d+\.\s/, '').trim());
    
    const afterAnalysis = analysisLines.slice(analysisEndIndex).join('\n');
    
    // Extract any links mentioned in the response
    const links = extractLinks(response);
    
    return {
      message: response,
      analysis: {
        steps: analysisSteps
      },
      links
    };
  }
  
  // For standard responses, just extract links
  return {
    message: response,
    analysis: null,
    links: extractLinks(response)
  };
}

// Helper function to extract links from response
function extractLinks(response) {
  const links = [];
  
  // Look for common link patterns in the text
  const accountDashboardMatch = response.match(/account dashboard|billing dashboard|payment settings/i);
  if (accountDashboardMatch) {
    links.push({
      title: 'Account Dashboard',
      url: 'https://app.example.com/account/billing'
    });
  }
  
  const helpCenterMatch = response.match(/help center|support article|knowledge base/i);
  if (helpCenterMatch) {
    links.push({
      title: 'Billing Help Center',
      url: 'https://help.example.com/billing'
    });
  }
  
  const refundPolicyMatch = response.match(/refund policy/i);
  if (refundPolicyMatch) {
    links.push({
      title: 'Refund Policy',
      url: 'https://www.example.com/legal/refunds'
    });
  }
  
  return links;
}

module.exports = router;
```

### Prompt Template Store

```javascript
// template-store.js
class TemplateStore {
  constructor() {
    this.templates = {
      standard: {
        'v1.0': this._getStandardTemplateV1(),
        'v1.1': this._getStandardTemplateV1_1(),
        'v1.2': this._getStandardTemplateV1_2()
      },
      cot: {
        'v1.0': this._getCoTTemplateV1()
      },
      account: {
        'v1.0': this._getAccountSpecificTemplateV1(),
        'v1.1': this._getAccountSpecificTemplateV1_1()
      },
      technical: {
        'v1.0': this._getTechnicalSupportTemplateV1()
      }
    };
  }
  
  async getTemplate(type, version) {
    if (!this.templates[type]) {
      throw new Error(`Template type "${type}" not found`);
    }
    
    if (!this.templates[type][version]) {
      throw new Error(`Template version "${version}" for type "${type}" not found`);
    }
    
    return this.templates[type][version];
  }
  
  _getStandardTemplateV1_2() {
    return `You are BillingAssist, a specialized customer support AI for {{product_name}}. Your role is to provide accurate, helpful information about billing issues while maintaining a professional, empathetic tone.

CONTEXT:
- You have knowledge of our subscription plans: {{pricing_info}}
- Billing occurs monthly or annually (with 20% discount)
- Payment methods include credit cards and PayPal
- Common issues include failed payments, upgrade/downgrade questions, refund requests, and invoice inquiries

CONSTRAINTS:
- Do not provide specific account details you don't have access to
- Never ask for full credit card information
- Don't make promises about exceptions to official policies
- If you cannot resolve an issue, direct customers to email billing@company.com

RESPONSE STRUCTURE:
1. Acknowledge the customer's issue
2. Provide relevant information about their billing question
3. Explain applicable policies clearly
4. Offer concrete next steps or solutions
5. Ask if they need further clarification

When discussing refunds, reference our refund policy: {{refund_policy}}
For payment failures, suggest checking payment details and explain our payment policy: {{payment_policy}}
For plan changes, explain prorated billing.

Always verify you've addressed the core issue before ending your response.

USER QUERY: {{user_query}}`;
  }
  
  _getCoTTemplateV1() {
    return `You are BillingAssist, a specialized customer support AI for {{product_name}}. Your role is to provide accurate, helpful information about billing issues while maintaining a professional, empathetic tone.

CONTEXT:
- You have knowledge of our subscription plans: {{pricing_info}}
- Billing occurs monthly or annually (with 20% discount)
- Payment methods include credit cards and PayPal
- Common issues include failed payments, upgrade/downgrade questions, refund requests, and invoice inquiries

CONSTRAINTS:
- Do not provide specific account details you don't have access to
- Never ask for full credit card information
- Don't make promises about exceptions to official policies
- If you cannot resolve an issue, direct customers to email billing@company.com

REASONING PROCESS:
For each customer query, follow this step-by-step reasoning process:
1. Identify the specific billing issue category (payment failure, refund, plan change, etc.)
2. Determine what policy information is relevant to this issue
3. Consider what additional information might be needed from the customer
4. Calculate any relevant figures (prorations, refund amounts, etc.) showing your work
5. Evaluate possible solutions based on company policies
6. Select the most appropriate solution or explanation

RESPONSE STRUCTURE:
1. Acknowledge the customer's issue
2. Show your reasoning process clearly labeled as "My Analysis:"
3. Provide relevant information about their billing question
4. Explain applicable policies clearly
5. Offer concrete next steps or solutions
6. Ask if they need further clarification

For refund calculations, show the original charge amount, applicable refund percentage, and final refund amount. For proration calculations, show the remaining days in billing period, daily rate, and resulting credit/charge.

When discussing refunds, reference our refund policy: {{refund_policy}}
For payment failures, suggest checking payment details and explain our payment policy: {{payment_policy}}

Always verify you've addressed the core issue before ending your response.

USER QUERY: {{user_query}}`;
  }
  
  // Other template methods omitted for brevity
  _getStandardTemplateV1() { /* ... */ }
  _getStandardTemplateV1_1() { /* ... */ }
  _getAccountSpecificTemplateV1() { /* ... */ }
  _getAccountSpecificTemplateV1_1() { /* ... */ }
  _getTechnicalSupportTemplateV1() { /* ... */ }
}

module.exports = new TemplateStore();
```

### LLM Service

```javascript
// llm-service.js
const { OpenAI } = require('openai');

class LLMService {
  constructor() {
    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY
    });
    this.lastPromptTokens = 0;
    this.lastResponseTokens = 0;
  }
  
  async generateResponse(prompt) {
    try {
      // Estimate prompt tokens (rough approximation)
      this.lastPromptTokens = Math.ceil(prompt.length / 4);
      
      const response = await this.openai.chat.completions.create({
        model: 'gpt-4',
        messages: [
          { role: 'system', content: prompt }
        ],
        temperature: 0.7,
        max_tokens: 1000
      });
      
      // Store response tokens
      this.lastResponseTokens = response.usage.completion_tokens;
      
      return response.choices[0].message.content;
    } catch (error) {
      console.error('Error calling OpenAI:', error);
      throw new Error('Failed to generate response from LLM');
    }
  }
  
  // Method to handle streaming responses if needed
  async generateStreamingResponse(prompt, onChunk) {
    try {
      const stream = await this.openai.chat.completions.create({
        model: 'gpt-4',
        messages: [
          { role: 'system', content: prompt }
        ],
        temperature: 0.7,
        max_tokens: 1000,
        stream: true
      });
      
      let fullResponse = '';
      
      for await (const chunk of stream) {
        const content = chunk.choices[0]?.delta?.content || '';
        fullResponse += content;
        onChunk(content);
      }
      
      // Estimate tokens (rough approximation)
      this.lastPromptTokens = Math.ceil(prompt.length / 4);
      this.lastResponseTokens = Math.ceil(fullResponse.length / 4);
      
      return fullResponse;
    } catch (error) {
      console.error('Error streaming from OpenAI:', error);
      throw new Error('Failed to generate streaming response from LLM');
    }
  }
}

module.exports = new LLMService();
```

## Example Implementations

### 1. Standard Billing Query Implementation

When a user asks a straightforward billing question, the system uses the standard refined prompt:

```javascript
// Example of handling a standard billing query
app.post('/api/billing-support/standard-example', (req, res) => {
  // Mock implementation for demonstration
  const userQuery = "How do I update my payment method?";
  
  // 1. Use the standard prompt template
  const prompt = `You are BillingAssist, a specialized customer support AI for ExampleSaaS. Your role is to provide accurate, helpful information about billing issues while maintaining a professional, empathetic tone.

CONTEXT:
- You have knowledge of our subscription plans: Basic ($10/month), Pro ($30/month), and Enterprise ($100/month)
- Billing occurs monthly or annually (with 20% discount)
- Payment methods include credit cards and PayPal
- Common issues include failed payments, upgrade/downgrade questions, refund requests, and invoice inquiries

CONSTRAINTS:
- Do not provide specific account details you don't have access to
- Never ask for full credit card information
- Don't make promises about exceptions to official policies
- If you cannot resolve an issue, direct customers to email billing@company.com

RESPONSE STRUCTURE:
1. Acknowledge the customer's issue
2. Provide relevant information about their billing question
3. Explain applicable policies clearly
4. Offer concrete next steps or solutions
5. Ask if they need further clarification

When discussing refunds, reference our 14-day refund policy.
For payment failures, suggest checking payment details and explain our 3-attempt retry process.
For plan changes, explain prorated billing.

Always verify you've addressed the core issue before ending your response.

USER QUERY: ${userQuery}`;

  // 2. Mock LLM response for demonstration
  const response = `I understand you'd like to update your payment method. I'm happy to help with that.

To update your payment method in ExampleSaaS:

1. Log in to your account at app.examplesaas.com
2. Navigate to "Account Settings" in the top-right dropdown menu
3. Select the "Billing" tab
4. Under "Payment Methods," click "Edit" or "Add New Method"
5. Enter your new payment details
6. Click "Save Changes"

Your next billing cycle will automatically use the new payment method. If you're updating your payment method because of a failed payment, this will also resolve any pending payment issues.

For security reasons, we never store complete credit card information, and all payment processing is handled securely through our payment processor.

Is there anything else you'd like to know about managing your payment methods?`;

  // 3. Return the response
  res.json({
    query: userQuery,
    response: response,
    promptType: 'standard'
  });
});
```

### 2. Complex Calculation Query Implementation

For queries involving calculations or complex reasoning, the system uses the Chain-of-Thought enhanced prompt:

```javascript
// Example of handling a complex calculation query
app.post('/api/billing-support/cot-example', (req, res) => {
  // Mock implementation for demonstration
  const userQuery = "I upgraded from Basic to Pro on the 15th of this month. My billing date is the 1st. How much will I be charged?";
  
  // 1. Use the CoT prompt template
  const prompt = `You are BillingAssist, a specialized customer support AI for ExampleSaaS. Your role is to provide accurate, helpful information about billing issues while maintaining a professional, empathetic tone.

CONTEXT:
- You have knowledge of our subscription plans: Basic ($10/month), Pro ($30/month), and Enterprise ($100/month)
- Billing occurs monthly or annually (with 20% discount)
- Payment methods include credit cards and PayPal
- Common issues include failed payments, upgrade/downgrade questions, refund requests, and invoice inquiries

CONSTRAINTS:
- Do not provide specific account details you don't have access to
- Never ask for full credit card information
- Don't make promises about exceptions to official policies
- If you cannot resolve an issue, direct customers to email billing@company.com

REASONING PROCESS:
For each customer query, follow this step-by-step reasoning process:
1. Identify the specific billing issue category (payment failure, refund, plan change, etc.)
2. Determine what policy information is relevant to this issue
3. Consider what additional information might be needed from the customer
4. Calculate any relevant figures (prorations, refund amounts, etc.) showing your work
5. Evaluate possible solutions based on company policies
6. Select the most appropriate solution or explanation

RESPONSE STRUCTURE:
1. Acknowledge the customer's issue
2. Show your reasoning process clearly labeled as "My Analysis:"
3. Provide relevant information about their billing question
4. Explain applicable policies clearly
5. Offer concrete next steps or solutions
6. Ask if they need further clarification

For refund calculations, show the original charge amount, applicable refund percentage, and final refund amount. For proration calculations, show the remaining days in billing period, daily rate, and resulting credit/charge.

Always verify you've addressed the core issue before ending your response.

USER QUERY: ${userQuery}`;

  // 2. Mock LLM response for demonstration
  const response = `I understand you're asking about the charges for upgrading from Basic to Pro on the 15th of the month, with your billing date being the 1st.

My Analysis:
1. Issue Category: Plan upgrade with proration calculation
2. Relevant Policy: When upgrading mid-cycle, we charge the prorated difference for the remainder of the billing period
3. Additional Information: We have the upgrade date (15th), billing date (1st), and the plans (Basic $10/month to Pro $30/month)
4. Calculations:
   - Days in a month (assuming 30 days): 30 days
   - Days remaining in billing cycle: 30 - 15 = 15 days
   - Basic plan daily rate: $10 / 30 = $0.33 per day
   - Pro plan daily rate: $30 / 30 = $1.00 per day
   - Credit for unused Basic: $0.33 × 15 = $4.95
   - Charge for new Pro: $1.00 × 15 = $15.00
   - Net additional charge: $15.00 - $4.95 = $10.05
5. Solution: Explain the prorated charge calculation and when it will be billed

Based on my analysis, for your upgrade from Basic to Pro on the 15th of the month, you'll be charged an additional $10.05 for the remainder of your billing cycle. This represents the prorated difference between the two plans for the 15 days left in your billing period.

Here's how it works:
- You receive a credit for the unused portion of your Basic plan ($4.95)
- You're charged for the new Pro plan for the remainder of the cycle ($15.00)
- The difference ($10.05) is charged immediately to your payment method

On your next regular billing date (the 1st of next month), you'll be charged the full monthly rate for the Pro plan ($30).

Would you like me to explain any other aspects of the proration calculation or billing process?`;

  // 3. Extract the analysis section
  const parts = response.split('My Analysis:');
  const beforeAnalysis = parts[0];
  const analysisAndRest = parts[1];
  const analysisLines = analysisAndRest.split('\n').filter(line => line.trim());
  
  // Find where the numbered list ends
  let analysisEndIndex = 0;
  for (let i = 0; i < analysisLines.length; i++) {
    if (!analysisLines[i].match(/^\d+\.\s/) && analysisEndIndex === 0) {
      analysisEndIndex = i;
      break;
    }
  }
  
  const analysisSteps = analysisLines.slice(0, analysisEndIndex)
    .map(line => line.replace(/^\d+\.\s/, '').trim());
  
  // 4. Return the response with structured analysis
  res.json({
    query: userQuery,
    message: response,
    analysis: {
      steps: analysisSteps
    },
    promptType: 'cot'
  });
});
```

## UI Mockups

### 1. Standard Response UI

```
┌─────────────────────────────────────────────────┐
│              Billing Support Assistant          │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ Hello! I'm your billing assistant.      │    │
│  │ How can I help you with your billing    │    │
│  │ questions today?                        │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
│                                ┌─────────────┐  │
│                                │ How do I    │  │
│                                │ update my   │  │
│                                │ payment     │  │
│                                │ method?     │  │
│                                └─────────────┘  │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ I understand you'd like to update your  │    │
│  │ payment method. I'm happy to help with  │    │
│  │ that.                                   │    │
│  │                                         │    │
│  │ To update your payment method in        │    │
│  │ ExampleSaaS:                            │    │
│  │                                         │    │
│  │ 1. Log in to your account at            │    │
│  │    app.examplesaas.com                  │    │
│  │ 2. Navigate to "Account Settings" in    │    │
│  │    the top-right dropdown menu          │    │
│  │ 3. Select the "Billing" tab             │    │
│  │ 4. Under "Payment Methods," click       │    │
│  │    "Edit" or "Add New Method"           │    │
│  │ 5. Enter your new payment details       │    │
│  │ 6. Click "Save Changes"                 │    │
│  │                                         │    │
│  │ Your next billing cycle will            │    │
│  │ automatically use the new payment       │    │
│  │ method.                                 │    │
│  │                                         │    │
│  │ Is there anything else you'd like to    │    │
│  │ know about managing your payment        │    │
│  │ methods?                                │    │
│  │                                         │    │
│  │ Helpful Resources:                      │    │
│  │ • Account Dashboard                     │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
├─────────────────────────────────────────────────┤
│ ┌─────────────────────────────────┐ ┌────────┐  │
│ │ Ask about billing...            │ │  Send  │  │
│ └─────────────────────────────────┘ └────────┘  │
├─────────────────────────────────────────────────┤
│  For urgent matters, contact billing@company.com │
└─────────────────────────────────────────────────┘
```

### 2. Chain-of-Thought Response UI

```
┌─────────────────────────────────────────────────┐
│              Billing Support Assistant          │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ Hello! I'm your billing assistant.      │    │
│  │ How can I help you with your billing    │    │
│  │ questions today?                        │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
│                                ┌─────────────┐  │
│                                │ I upgraded  │  │
│                                │ from Basic  │  │
│                                │ to Pro on   │  │
│                                │ the 15th.   │  │
│                                │ My billing  │  │
│                                │ date is the │  │
│                                │ 1st. How    │  │
│                                │ much will I │  │
│                                │ be charged? │  │
│                                └─────────────┘  │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ I understand you're asking about the    │    │
│  │ charges for upgrading from Basic to     │    │
│  │ Pro on the 15th of the month, with      │    │
│  │ your billing date being the 1st.        │    │
│  │                                         │    │
│  │ My Analysis:                            │    │
│  │ 1. Issue Category: Plan upgrade with    │    │
│  │    proration calculation                │    │
│  │ 2. Relevant Policy: When upgrading      │    │
│  │    mid-cycle, we charge the prorated    │    │
│  │    difference for the remainder of the  │    │
│  │    billing period                       │    │
│  │ 3. Additional Information: We have the  │    │
│  │    upgrade date (15th), billing date    │    │
│  │    (1st), and the plans (Basic $10/mo   │    │
│  │    to Pro $30/mo)                       │    │
│  │ 4. Calculations:                        │    │
│  │    - Days in month: 30 days             │    │
│  │    - Days remaining: 15 days            │    │
│  │    - Basic daily rate: $0.33/day        │    │
│  │    - Pro daily rate: $1.00/day          │    │
│  │    - Credit for unused Basic: $4.95     │    │
│  │    - Charge for new Pro: $15.00         │    │
│  │    - Net charge: $10.05                 │    │
│  │ 5. Solution: Explain the prorated       │    │
│  │    charge calculation                   │    │
│  │                                         │    │
│  │ Based on my analysis, you'll be         │    │
│  │ charged an additional $10.05 for the    │    │
│  │ remainder of your billing cycle.        │    │
│  │                                         │    │
│  │ Here's how it works:                    │    │
│  │ - You receive a credit for the unused   │    │
│  │   portion of your Basic plan ($4.95)    │    │
│  │ - You're charged for the new Pro plan   │    │
│  │   for the remainder of the cycle        │    │
│  │   ($15.00)                              │    │
│  │ - The difference ($10.05) is charged    │    │
│  │   immediately                           │    │
│  │                                         │    │
│  │ On your next regular billing date (the  │    │
│  │ 1st), you'll be charged the full        │    │
│  │ monthly rate for the Pro plan ($30).    │    │
│  │                                         │    │
│  │ Would you like me to explain any other  │    │
│  │ aspects of the calculation?             │    │
│  │                                         │    │
│  │ Helpful Resources:                      │    │
│  │ • Billing Help Center                   │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
├─────────────────────────────────────────────────┤
│ ┌─────────────────────────────────┐ ┌────────┐  │
│ │ Ask about billing...            │ │  Send  │  │
│ └─────────────────────────────────┘ └────────┘  │
├─────────────────────────────────────────────────┤
│  For urgent matters, contact billing@company.com │
└─────────────────────────────────────────────────┘
```

## Integration with SaaS Product

### 1. Embedding in Customer Dashboard

```html
<!-- customer-dashboard.html -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Customer Dashboard | ExampleSaaS</title>
  <link rel="stylesheet" href="/css/dashboard.css">
  <link rel="stylesheet" href="/css/billing-assistant.css">
</head>
<body>
  <header>
    <nav>
      <div class="logo">ExampleSaaS</div>
      <ul class="nav-links">
        <li><a href="/dashboard">Dashboard</a></li>
        <li><a href="/account">Account</a></li>
        <li class="active"><a href="/billing">Billing</a></li>
        <li><a href="/support">Support</a></li>
      </ul>
      <div class="user-menu">
        <img src="/img/avatar.png" alt="User Avatar">
        <span>John Doe</span>
      </div>
    </nav>
  </header>
  
  <main class="dashboard-container">
    <aside class="sidebar">
      <ul>
        <li><a href="/billing/overview">Overview</a></li>
        <li><a href="/billing/invoices">Invoices</a></li>
        <li><a href="/billing/payment-methods">Payment Methods</a></li>
        <li><a href="/billing/subscription">Subscription</a></li>
        <li class="active"><a href="/billing/support">Billing Support</a></li>
      </ul>
    </aside>
    
    <section class="content-area">
      <div class="page-header">
        <h1>Billing Support</h1>
        <button class="btn secondary">Contact Support Team</button>
      </div>
      
      <div class="billing-support-container">
        <div class="support-options">
          <h2>Common Billing Questions</h2>
          <ul class="quick-links">
            <li><a href="#" class="preset-question" data-question="How do I update my payment method?">Update payment method</a></li>
            <li><a href="#" class="preset-question" data-question="When will my next payment be charged?">Next payment date</a></li>
            <li><a href="#" class="preset-question" data-question="How do I download an invoice?">Download invoice</a></li>
            <li><a href="#" class="preset-question" data-question="What happens if my payment fails?">Payment failures</a></li>
            <li><a href="#" class="preset-question" data-question="How do I cancel my subscription?">Cancel subscription</a></li>
          </ul>
          
          <h2>Recent Invoices</h2>
          <table class="invoice-table">
            <thead>
              <tr>
                <th>Date</th>
                <th>Amount</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>May 1, 2025</td>
                <td>$30.00</td>
                <td><span class="status paid">Paid</span></td>
                <td><a href="#">View</a></td>
              </tr>
              <tr>
                <td>Apr 1, 2025</td>
                <td>$30.00</td>
                <td><span class="status paid">Paid</span></td>
                <td><a href="#">View</a></td>
              </tr>
              <tr>
                <td>Mar 1, 2025</td>
                <td>$10.00</td>
                <td><span class="status paid">Paid</span></td>
                <td><a href="#">View</a></td>
              </tr>
            </tbody>
          </table>
        </div>
        
        <!-- Billing Assistant Chat Component -->
        <div id="billing-assistant-root"></div>
      </div>
    </section>
  </main>
  
  <script src="/js/react.production.min.js"></script>
  <script src="/js/react-dom.production.min.js"></script>
  <script src="/js/billing-assistant-bundle.js"></script>
  <script>
    // Initialize the Billing Assistant with user context
    document.addEventListener('DOMContentLoaded', function() {
      const userContext = {
        userId: '12345',
        sessionToken: 'abc123xyz789',
        plan: 'Pro',
        billingDate: '2025-06-01'
      };
      
      // Mount the React component
      BillingAssistant.init('billing-assistant-root', userContext);
      
      // Add event listeners for preset questions
      document.querySelectorAll('.preset-question').forEach(link => {
        link.addEventListener('click', function(e) {
          e.preventDefault();
          const question = this.getAttribute('data-question');
          BillingAssistant.askQuestion(question);
        });
      });
    });
  </script>
</body>
</html>
```

### 2. Mobile App Integration

```swift
// BillingAssistantViewController.swift (iOS)
import UIKit
import WebKit

class BillingAssistantViewController: UIViewController {
    
    private let webView = WKWebView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let userToken: String
    
    init(userToken: String) {
        self.userToken = userToken
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Billing Support"
        view.backgroundColor = .systemBackground
        
        setupWebView()
        setupLoadingIndicator()
        loadBillingAssistant()
    }
    
    private func setupWebView() {
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        webView.navigationDelegate = self
    }
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
    }
    
    private func loadBillingAssistant() {
        // Create URL with authentication token
        guard var urlComponents = URLComponents(string: "https://app.example.com/mobile/billing-assistant") else {
            showError("Invalid URL")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "token", value: userToken),
            URLQueryItem(name: "platform", value: "ios"),
            URLQueryItem(name: "version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown")
        ]
        
        guard let url = urlComponents.url else {
            showError("Could not create URL")
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func showError(_ message: String) {
        loadingIndicator.stopAnimating()
        
        let alert = UIAlertController(
            title: "Error",
            message: "Could not load billing assistant: \(message)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.loadBillingAssistant()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
}

extension BillingAssistantViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showError(error.localizedDescription)
    }
}
```

## Testing and Evaluation

### 1. A/B Testing Implementation

```javascript
// ab-testing-service.js
class ABTestingService {
  constructor(analyticsService) {
    this.analyticsService = analyticsService;
    this.tests = {
      'billing-assistant-prompt': {
        variants: ['standard', 'cot'],
        distribution: [0.5, 0.5], // 50% standard, 50% CoT
        active: true
      }
    };
  }
  
  getVariant(testName, userId) {
    const test = this.tests[testName];
    
    if (!test || !test.active) {
      return 'standard'; // Default to standard if test doesn't exist or is inactive
    }
    
    // Use userId to consistently assign the same variant to the same user
    const hash = this._hashString(userId + testName);
    const normalizedHash = (hash % 100) / 100; // Convert to value between 0-1
    
    // Determine which variant based on distribution
    let cumulativeProbability = 0;
    for (let i = 0; i < test.variants.length; i++) {
      cumulativeProbability += test.distribution[i];
      if (normalizedHash < cumulativeProbability) {
        // Log the assignment for analytics
        this.analyticsService.trackEvent('ab_test_assignment', {
          testName,
          userId,
          variant: test.variants[i]
        });
        
        return test.variants[i];
      }
    }
    
    // Fallback to first variant
    return test.variants[0];
  }
  
  _hashString(str) {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return Math.abs(hash);
  }
}

module.exports = ABTestingService;
```

### 2. Evaluation Metrics Collection

```javascript
// evaluation-service.js
class EvaluationService {
  constructor(db) {
    this.db = db;
  }
  
  async recordInteraction(data) {
    const {
      userId,
      conversationId,
      queryType,
      promptType,
      query,
      response,
      responseTime,
      tokenUsage
    } = data;
    
    // Store the interaction data
    await this.db.collection('interactions').insertOne({
      userId,
      conversationId,
      queryType,
      promptType,
      query,
      response,
      responseTime,
      tokenUsage,
      timestamp: new Date()
    });
  }
  
  async recordFeedback(data) {
    const {
      conversationId,
      userId,
      helpfulRating,
      accuracyRating,
      clarityRating,
      comments,
      followupNeeded
    } = data;
    
    // Store the feedback
    await this.db.collection('feedback').insertOne({
      conversationId,
      userId,
      helpfulRating,
      accuracyRating,
      clarityRating,
      comments,
      followupNeeded,
      timestamp: new Date()
    });
    
    // Update aggregate metrics
    await this.updateAggregateMetrics(data);
  }
  
  async updateAggregateMetrics(feedbackData) {
    // Get the interaction data
    const interaction = await this.db.collection('interactions')
      .findOne({ conversationId: feedbackData.conversationId });
    
    if (!interaction) return;
    
    // Update metrics for this prompt type
    await this.db.collection('prompt_metrics').updateOne(
      { promptType: interaction.promptType },
      {
        $inc: {
          totalInteractions: 1,
          totalHelpfulRating: feedbackData.helpfulRating,
          totalAccuracyRating: feedbackData.accuracyRating,
          totalClarityRating: feedbackData.clarityRating,
          followupNeeded: feedbackData.followupNeeded ? 1 : 0
        }
      },
      { upsert: true }
    );
  }
  
  async getPromptTypeComparison() {
    const metrics = await this.db.collection('prompt_metrics').find().toArray();
    
    // Calculate averages and comparison
    const result = metrics.map(m => ({
      promptType: m.promptType,
      averageHelpful: m.totalHelpfulRating / m.totalInteractions,
      averageAccuracy: m.totalAccuracyRating / m.totalInteractions,
      averageClarity: m.totalClarityRating / m.totalInteractions,
      followupRate: m.followupNeeded / m.totalInteractions,
      totalInteractions: m.totalInteractions
    }));
    
    return result;
  }
}

module.exports = EvaluationService;
```

## Conclusion

This implementation guide provides a comprehensive framework for implementing the billing support assistant with both the refined prompt and Chain-of-Thought enhanced versions. The code samples demonstrate:

1. How to create a responsive, user-friendly chat interface
2. How to implement backend services for prompt management and LLM integration
3. How to dynamically select between standard and CoT prompts based on query complexity
4. How to extract and display the reasoning process from CoT responses
5. How to integrate the assistant into web and mobile applications
6. How to implement A/B testing and collect evaluation metrics

By following this implementation approach, organizations can provide their customers with a more transparent, accurate, and helpful billing support experience, particularly for complex scenarios involving calculations or policy interpretations.
