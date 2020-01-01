import derelict.glfw3;
import derelict.opengl3.gl3;
import std.file;
import std.stdio;
import imageformats.jpeg;

static GLFWwindow* window;
static uint vertexBufferId;
static uint vertexCount;
static uint program;
static uint texture;

static float[] quad = [
	-0.5, -0.5, 0.0, 0.0,
	-0.5,  0.5, 0.0, 1.0,
     0.5,  0.5, 1.0, 1.0,
	-0.5, -0.5, 0.0, 0.0,
	 0.5,  0.5, 1.0, 1.0,
	 0.5, -0.5, 1.0, 0.0
];

void initializeDisplay(int width, int height)
{
	glfwInit();
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);

	window = glfwCreateWindow(width, height, "Window Title", null, null);
	glfwMakeContextCurrent(window);

	DerelictGL3.load();
	DerelictGL3.reload();

	uint vao;
	glGenVertexArrays(1, &vao);
	glBindVertexArray(vao);

	glClearColor(0.1, 0.2, 0.3, 1.0);
}

void setupScene()
{
	// Create the quad to render
	glGenBuffers(1, &vertexBufferId);
	glBindBuffer(GL_ARRAY_BUFFER, vertexBufferId);
	glBufferData(GL_ARRAY_BUFFER, quad.length * float.sizeof, quad.ptr, GL_STATIC_DRAW);
	vertexCount = cast(uint) quad.length / 4;

	char[512] errorBuffer;
	int errorLength;

	// Load the render shader
	uint fs = glCreateShader(GL_FRAGMENT_SHADER);
	string fsSource = readText("fs.glsl");
	const char* fsSrc = cast(const char*)fsSource.ptr;
	const int fsLen = cast(const int)fsSource.length;
	glShaderSource(fs, 1, &fsSrc, &fsLen);
	glCompileShader(fs);
	glGetShaderInfoLog(fs, 512, &errorLength, errorBuffer.ptr);

	uint vs = glCreateShader(GL_VERTEX_SHADER);
	string vsSource = readText("vs.glsl");
	const char* vsSrc = cast(const char*)vsSource.ptr;
	const int vsLen = cast(const int)vsSource.length;
	glShaderSource(vs, 1, &vsSrc, &vsLen);
	glCompileShader(vs);
	glGetShaderInfoLog(vs, 512, &errorLength, errorBuffer.ptr);

	program = glCreateProgram();
	glAttachShader(program, fs);
	glAttachShader(program, vs);
	glLinkProgram(program);

	// Load the texture
	auto image = read_jpeg("bricks.jpg");

	auto pixels = image.pixels.ptr;

	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, image.w, image.h, 0, GL_RGB, GL_UNSIGNED_BYTE, pixels);
	glGenerateMipmap(GL_TEXTURE_2D);

	// Bind the texture to the sampler
	glUniform1i(glGetUniformLocation(program, "tex"), texture);
}

void renderScene()
{
	glClear(GL_COLOR_BUFFER_BIT);

	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, texture);
	glEnable(GL_TEXTURE_2D);

	glBindBuffer(GL_ARRAY_BUFFER, vertexBufferId);
	glUseProgram(program);

	glEnableVertexAttribArray(0);
	glEnableVertexAttribArray(1);

	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 4 * float.sizeof, cast(void*)0);
	glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 4 * float.sizeof, cast(void*)8);

	glDrawArrays(GL_TRIANGLES, 0, vertexCount);
}

void runMainLoop()
{
	while (!glfwWindowShouldClose(window))
	{
		glfwPollEvents();
		renderScene();
		glfwSwapBuffers(window);
	}
}

void main()
{
	initializeDisplay(1400, 800);
	setupScene();
	runMainLoop();
}
