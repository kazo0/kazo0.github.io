---
title: "Adding Agent Skills To Your Uno Platform AI Tool Belt"
category: uno-tidbit
header:
  teaser: /assets/images/tidbit-hero.png
  og_image: /assets/images/tidbit-hero.png
tags: [uno-tidbits, uno-tidbit, tidbit, Agents, AI, MCP, skills, uno-platform, uno, unoplatform]
---

Uno Platform has been making some great strides in AI-assisted development recently. At its core, Uno still continues to be one of the best cross-platform .NET UI frameworks out there. Now, in the age of agentic development, a great framework also needs to be paired with a robust tooling ecosystem. I would highly recommend checking out some of the recent developments surrounding AI-assisted development in Uno, such as Jerome's[jerome-social] presentation from this past .NET Conf:

{% include video id="g4A_3ZCwwWg" provider="youtube" %}

As well as some great articles the team has been publishing on the blog, including [this one from Matthew Mattei][matthew-agent-blog].

## The Problem

The tooling ecosystem for Uno Platform is evolving rapidly and offers two very important tools for agentic development: The Uno MCP and the Uno App MCP. For a good breakdown of these tools and how to use them, check out the [Uno MCP vs App MCP blog post][uno-mcp-blog]. While these are quite powerful on their own, you may find that your agents aren't always reliably using them for every scenario. Take the Uno MCP for example, it basically provides the agent with a way of accessing the entire [Uno documentation][uno-docs] as a knowledge base. This is great, however, this means that that MCP's capabilities are exposed to the agent in a very broad and general way. The agent may not always "know" that the Uno MCP tools such as `uno_platform_search_docs` are capable of answering specific questions. For example, if the agent is trying to implement something like [Selection with MVUX][mvux-selection], it may not reliably search the relevant docs as nothing is really telling the agent "Hey! MVUX related questions can be answered by searching the Uno docs with the Uno MCP tool `uno_platform_search_docs`!".

## The Solution: Agent Skills

Agent Skills are what bridges this gap between the agent and its available tool calls. A good analogy from the [Uno Skills blog post][uno-skills-blog] define the MCP tools as the ingredients and Agent Skills as the recipes. I like to think of skills as the glue that binds the agent to the MCP tools.

Let's circle back to the example of implementing selection with MVUX. A skill can expose to the agent that it knows about MVUX selection and can instruct the agent to search and fetch specific documentation surrounding that topic. Now, the very broad-reaching Uno MCP has been limited to a small set of relevant information for the task at hand.

## Creating An Agent Skill

As a first attempt at creating a skill for MVUX selection, I instructed the agent itself to use the Uno MCP to gather all information on MVUX selection and create a skill out of that.

The initial skill looked something like this:


This will indeed work to guide the agent towards a proper implementation. But, as you can see, this skill file is simply a copy-paste of the Uno documentation on MVUX selection. This is not ideal for a few reasons:

1. This is a lot of content that gets loaded into the agent's context window every time it needs to use this skill.
2. Instead of instructing the agent on how to use the Uno MCP tools, it is basically doing the job of the Uno MCP itself by providing the agent with all the relevant information upfront.
3. This skill is not very maintainable, as any updates to the Uno documentation on MVUX selection would require manually updating this skill file as well.

Re-prompting the agent to refactor this into a lightweight skill that utilizes the Uno MCP tools provided the following result:


This is a much cleaner, more maintainable, and more efficient skill. Now the question is, how well does this work in practice? Does it really make a difference in the agent's ability to implement MVUX selection?

## Using Agent Skills

First thing's first, let's create a new Uno app with the Recommended preset template.

```bash
dotnet new unoapp -preset recommended -o MVUXSelectionApp 
```

We start with a two page application. We have a `MainPage` and a `SecondPage` backed by MVUX models. The `MainPage` simply has a `TextBox` and a `Button` to navigate to the `SecondPage` while passing along the text from the `TextBox`. The `SecondPage` has a `TextBlock` that displays the text passed from the `MainPage`.

`MainPage.xaml`:

```xml
<Page x:Class="MVUXSelectionApp.Presentation.MainPage"
      xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
      xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
      xmlns:local="using:MVUXSelectionApp.Presentation"
      xmlns:uen="using:Uno.Extensions.Navigation.UI"
      xmlns:utu="using:Uno.Toolkit.UI"
      xmlns:um="using:Uno.Material"
      NavigationCacheMode="Required"
      Background="{ThemeResource BackgroundBrush}">
    <ScrollViewer IsTabStop="True">
        <Grid utu:SafeArea.Insets="VisibleBounds">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition />
            </Grid.RowDefinitions>
            <utu:NavigationBar Content="{Binding Title}"/>
            <StackPanel Grid.Row="1"
                        HorizontalAlignment="Center"
                        VerticalAlignment="Center"
                        Spacing="16">
                <TextBox Text="{Binding Name, Mode=TwoWay}"
                         PlaceholderText="Enter your name:"/>
                <Button Content="Go to Second Page"
                        AutomationProperties.AutomationId="SecondPageButton"
                        Command="{Binding GoToSecond}"/>
            </StackPanel>
        </Grid>
    </ScrollViewer>
</Page>
```

`MainModel.cs`:

```csharp
public partial record MainModel
{
    private INavigator _navigator;

    public MainModel(
        IStringLocalizer localizer,
        IOptions<AppConfig> appInfo,
        INavigator navigator)
    {
        //...
    }

    public IState<string> Name => State<string>.Value(this, () => string.Empty);

    public async Task GoToSecond()
    {
        var name = await Name;
        await _navigator.NavigateViewModelAsync<SecondModel>(this, data: new Entity(name!));
    }

}
```

With this app loaded up, and without the MVUX selection skill, we can give an agent a prompt such as:

> Instead of a TextBox on the MainPage, I want to display a simple list of names ("Kunal", "Vatsa", "Matthew", "Skander", "Rafael", "Ramez") and it should support single selection that will pass that name to the Second Page when GoToSecond is fired

```diff
 public partial record MainModel
 { 
   private INavigator _navigator;
   public MainModel(
       IStringLocalizer localizer,
       IOptions<AppConfig> appInfo,
       INavigator navigator)
   {
       //...
   }
   
   public string? Title { get; }
   
- public IListFeed<string> Names => ListFeed.Async(this, async ct =>
-     ImmutableList.Create("Kunal", "Vatsa", "Matthew", "Skander", "Rafael", "Ramez"));
+ public IState<string> Name => State<string>.Value(this, () => string.Empty);
   
- public IState<string> SelectedName => State<string>.Value(this, () => string.Empty);
- 
   public async Task GoToSecond()
   {
-     var name = await SelectedName;
-     await _navigator.NavigateViewModelAsync<SecondModel>(this, data: new Entity(name ??  string.Empty));
+     var name = await Name;
+     await _navigator.NavigateViewModelAsync<SecondModel>(this, data: new Entity(name!));
   }
 }
```

That's it! We now have a fancy carousel experience that works on all platforms and screen sizes.

You can check out a working example of this in the [CarouselApp repository][carousel-gh] on GitHub.

Catch you in the next one :wave:

[uno-toolkit-repo]: https://github.com/unoplatform/uno.toolkit.ui
[carousel-gh]: https://github.com/kazo0/CarouselApp
[responsive-markup-extensions]: https://platform.uno/docs/articles/external/uno.toolkit.ui/doc/helpers/responsive-extension.html 
[selector-extensions]: https://platform.uno/docs/articles/external/uno.toolkit.ui/doc/helpers/Selector-extensions.html
[ms-flipview-doc]: https://learn.microsoft.com/en-us/windows/apps/design/controls/flipview#adding-a-context-indicator
[jerome-social]: https://twitter.com/jerome_laban
[matthew-agent-blog]: https://platform.uno/blog/an-easy-agentic-workflow-for-developing-with-uno-platform-mcps/
[uno-mcp-blog]: https://platform.uno/blog/uno-mcp-vs-app-mcp/
[uno-docs]: https://platform.uno/docs/articles/intro.html
[mvux-selection]: https://platform.uno/docs/articles/external/uno.extensions/doc/Learn/Mvux/Advanced/Selection.html
[uno-skills-blog]: https://platform.uno/blog/contextual-ai-mcptools-vs-skills/