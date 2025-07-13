
</head>
<body>

  <h1>FormLang++ – A Domain-Specific Language for HTML Form Generation</h1>

  <p><strong>FormLang++</strong> is a <strong>domain-specific language (DSL)</strong> developed using <strong>Flex (Lex)</strong> and <strong>Bison (Yacc)</strong> to simplify the creation of HTML forms through high-level, human-readable syntax. Instead of manually writing repetitive HTML code, developers can use FormLang++ to define forms declaratively, which are then compiled into structured HTML output.</p>

  <blockquote><strong>📌 Developed as part of the Programming Paradigms coursework at SLIIT.</strong></blockquote>

  <h2>🚀 Features</h2>
  <ul>
    <li>High-level form syntax for common HTML elements like <code>input</code>, <code>textarea</code>, <code>select</code>, <code>radio</code>, and <code>checkbox</code>.</li>
    <li>Built-in validations for required fields, input types, and duplicate field names.</li>
    <li>Semantic error handling with meaningful messages.</li>
    <li>Generates clean, valid HTML code from FormLang++ scripts.</li>
    <li>Extensible grammar for adding more form types or customization options.</li>
  </ul>

  <h2>🛠 Technologies Used</h2>
  <ul>
    <li><strong>Flex (Lex)</strong> – Lexical analysis</li>
    <li><strong>Bison (Yacc)</strong> – Grammar parsing</li>
    <li><strong>C</strong> – Backend and code generation</li>
    <li><strong>Makefile</strong> – Build automation</li>
  </ul>

  <h2>📂 Project Structure</h2>
  <pre>
FormLang++
├── lexer.l              # Lex file: Token definitions
├── parser.y             # Yacc file: Grammar rules
├── form_generator.c     # Code generation logic
├── form_test.form       # Sample FormLang++ input
├── Makefile             # Build instructions
└── README.md            # Documentation
  </pre>

  <h2>📄 Sample FormLang++ Code</h2>
  <pre><code>form "Contact Us"
input "Name" name:text required
input "Email" email:email required
textarea "Message" message required
submit "Send Message"
  </code></pre>

  <p><strong>➡️ Generated HTML Output:</strong></p>
  <pre><code>&lt;form&gt;
  &lt;label&gt;Name&lt;/label&gt;
  &lt;input type="text" name="name" required&gt;

  &lt;label&gt;Email&lt;/label&gt;
  &lt;input type="email" name="email" required&gt;

  &lt;label&gt;Message&lt;/label&gt;
  &lt;textarea name="message" required&gt;&lt;/textarea&gt;

  &lt;button type="submit"&gt;Send Message&lt;/button&gt;
&lt;/form&gt;
  </code></pre>

  <h2>🧪 How to Build and Run</h2>
  <ol>
    <li><strong>Clone the Repository</strong>
      <pre><code>git clone https://github.com/yourusername/formlangplusplus.git
cd formlangplusplus</code></pre>
    </li>
    <li><strong>Build the Compiler</strong>
      <pre><code>make</code></pre>
    </li>
    <li><strong>Run the DSL Parser</strong>
      <pre><code>./formlang form_test.form</code></pre>
    </li>
    <li><strong>Check Output</strong>  
      <p>The generated HTML will be printed to the terminal or saved to an output file, depending on the implementation.</p>
    </li>
  </ol>

  <h2>👨‍💻 Author</h2>
  <p><strong>Venuja Ranasinghe</strong><br/>
  Computer Science Undergraduate, SLIIT<br/>
  <a href="https://linkedin.com/in/your-profile">LinkedIn</a> | 
  <a href="https://your-portfolio-link.com">Portfolio</a></p>


  <h2>🤝 Contributions</h2>
  <p>Contributions are welcome! Feel free to fork the repo, improve the grammar, or enhance the output logic, and submit a pull request.</p>

</body>
</html>
