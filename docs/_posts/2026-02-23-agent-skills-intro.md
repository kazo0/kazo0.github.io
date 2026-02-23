---
title: "Agent Skills + Uno Platform"
category: uno-general
header:
  teaser: /assets/images/skills-intro/tool-hero.png
  og_image: /assets/images/skills-intro/tool-hero.png
tags: [Agents, AI, MCP, skills, uno-platform, uno, unoplatform]
---

Uno Platform has been making some great strides in AI-assisted development recently. At its core, Uno still continues to be one of the best cross-platform .NET UI frameworks out there. Now, in the age of agentic development, a great framework also needs to be paired with a robust tooling ecosystem. I would highly recommend checking out some of the recent developments surrounding AI-assisted development in Uno, such as [Jerome's][jerome-social] presentation from this past .NET Conf:

{% include video id="g4A_3ZCwwWg" provider="youtube" %}

As well as some great articles the team has been publishing on the blog, including [this one from Matthew Mattei][matthew-agent-blog].

## The Problem

The tooling ecosystem for Uno Platform is evolving rapidly and offers two very important tools for agentic development: The Uno MCP and the Uno App MCP. For a good breakdown of these tools and how to use them, check out the [Uno MCP vs App MCP blog post][uno-mcp-blog].

While these are quite powerful on their own, you may find that your agents aren't always reliably using them for every scenario. Take the Uno MCP for example, it basically provides the agent with a way of accessing the entire [Uno documentation][uno-docs] as a knowledge base. This is great, however, this means that the MCP's capabilities are exposed to the agent in a very broad and general way. The agent may not always "know" that the Uno MCP tools, such as `uno_platform_docs_search`, are capable of answering specific questions.

For example, if the agent is trying to implement something like [Selection with MVUX][mvux-selection], it may not reliably search the relevant docs as nothing is really telling the agent "Hey! MVUX related questions can be answered by searching the Uno docs with the Uno MCP tool `uno_platform_docs_search`!".

## The Solution: Agent Skills

Agent Skills are what bridges this gap between the agent and its available tool calls. A good analogy from the [Uno Skills blog post][uno-skills-blog] defines the MCP tools as the ingredients and Agent Skills as the recipes. I like to think of skills as the glue that binds the agent to the MCP tools.

Let's circle back to the example of implementing selection with MVUX. A skill can expose to the agent that it knows about MVUX selection and can instruct the agent to search and fetch specific documentation surrounding that topic. With that, the very broad-reaching Uno MCP has now been limited in scope to a small set of relevant information for the task at hand.

## Creating An Agent Skill

As a first attempt at creating a skill for MVUX selection, I instructed the agent itself to use the Uno MCP to gather all information on MVUX selection and create a skill out of that.

I have uploaded the [initially generated skill][initial-skill-md] to this [mvux-selection-skill][mvux-selection-skill-gh] repo.

This will indeed work to guide the agent towards a proper implementation. But, as you can see, this skill file is simply a copy-paste of the Uno documentation on MVUX selection. This is not ideal for a few reasons:

1. This is a lot of content that gets loaded into the agent's context window every time it needs to use this skill.
2. Instead of instructing the agent on how to use the Uno MCP tools, it is basically doing the job of the Uno MCP itself by providing the agent with all the relevant information upfront.
3. This skill is not very maintainable, as any updates to the Uno documentation on MVUX selection would require manually updating this skill file as well.

Re-prompting the agent to refactor this into a lightweight skill that utilizes the Uno MCP tools provided the [following result][refactored-skill-md].

This is a much cleaner, more maintainable, and more efficient skill. Now the question is, how well does this work in practice? Does it really make a difference in the agent's ability to implement MVUX selection?

## Using Agent Skills

First thing's first, let's create a new Uno app with the Recommended preset template.

```bash
dotnet new unoapp -preset recommended -o MVUXSelectionApp 
```

We start with a two page application. We have a `MainPage` and a `SecondPage` backed by MVUX models. The `MainPage` simply has a `TextBox` and a `Button` to navigate to the `SecondPage` while passing along the text from the `TextBox`. The `SecondPage` has a `TextBlock` that displays the text passed from the `MainPage`.

### Initial Code

#### `MainPage.xaml`

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

#### `MainModel.cs`

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

### Modified Code without MVUX Selection Skill

#### `MainPage.xaml`

```diff
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
-                 <TextBox Text="{Binding Name, Mode=TwoWay}"
-                          PlaceholderText="Enter your name:"/>
+                 <TextBlock Text="Select a name:"
+                            Style="{StaticResource TitleTextBlockStyle}"/>
+                 <ListView ItemsSource="{Binding Names}"
+                           uen:Selection.Selected="{Binding SelectedName}"
+                           SelectionMode="Single"
+                           MinWidth="200"/>
                 <Button Content="Go to Second Page"
                         AutomationProperties.AutomationId="SecondPageButton"
                         Command="{Binding GoToSecond}"/>
             </StackPanel>
         </Grid>
     </ScrollViewer>
 </Page>
```

#### `MainModel.cs`

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
   
+  public IListFeed<string> Names => ListFeed.Async(this, async ct =>
+    ImmutableList.Create("Kunal", "Vatsa", "Matthew", "Skander", "Rafael", "Ramez"));
-  public IState<string> Name => State<string>.Value(this, () => string.Empty);
   
+  public IState<string> SelectedName => State<string>.Value(this, () => string.Empty);
 
   public async Task GoToSecond()
   {
+     var name = await SelectedName;
+     await _navigator.NavigateViewModelAsync<SecondModel>(this, data: new Entity(name ??  string.Empty));
-     var name = await Name;
-     await _navigator.NavigateViewModelAsync<SecondModel>(this, data: new Entity(name!));
   }
 }
```

Here's a look at the agent running through this process:

{% include video id="12HyT23vYuNGaLIYL0To9-Wp6ZfrPmYF5" provider="google-drive" %}

As it stands from this snapshot in time, the current code does not compile

- There is no notion of a `uen:Selection.Selected` attached property in the Uno.Extensions.Navigation.UI namespace
- The signature of the `ListFeed.Async` method is also incorrect, it only needs a single parameter of type `AsyncFunc<...>`
- The new `IState<string> SelectedName` property is not being properly bound to the `IListFeed<string> Names`

Note that the code pasted above is the initial generation from the agent without the MVUX selection skill. While not completely correct, it did eventually iterate on itself, fixing the build failures and eventually got to a working solution.

Now, let's try this again with the same prompt, but this time with the skill included at `.claude/skills/mvux-selection/SKILL.md`.

Here's a run of the agent with the MVUX selection skill:

{% include video id="1G-R8y6EBGGcvQNnt1Za0Po7D61Zmapes" provider="google-drive" %}

You may have noticed that I added a little bit of extra instruction to the prompt:

> Run the desktop target afterward and confirm the expected behaviour

You can see by the end of the video, the agent starts up the app, selects a name from the `ListView`, and verifies that the correct name is displayed on the `SecondPage`. This was all done autonomously by the agent using the Uno App MCP.

### Modified Code with MVUX Selection Skill

Here are the diffs of what the agent was able to generate with the MVUX selection skill:

#### `MainPage.xaml`

```diff
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
-                 <TextBox Text="{Binding Name, Mode=TwoWay}"
-                          PlaceholderText="Enter your name:"/>
+                 <TextBlock Text="Select a name:"
+                            Style="{StaticResource TitleMedium}"/>
+                 <ListView ItemsSource="{Binding Names}"
+                           SelectionMode="Single" />
                 <Button Content="Go to Second Page"
                         AutomationProperties.AutomationId="SecondPageButton"
                         Command="{Binding GoToSecond}"/>
             </StackPanel>
         </Grid>
     </ScrollViewer>
 </Page>
```

#### `MainModel.cs`

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
   
+  public IListFeed<string> Names => ListFeed
+   .Async(async ct => ImmutableList.Create("Kunal", "Vatsa", "Matthew", "Skander", "Rafael", "Ramez"))
+   .Selection(SelectedName);
-  public IState<string> Name => State<string>.Value(this, () => string.Empty);
   
+  public IState<string> SelectedName => State<string>.Value(this, () => string.Empty);
 
   public async Task GoToSecond()
   {
+     var name = await SelectedName;
+     await _navigator.NavigateViewModelAsync<SecondModel>(this, data: new Entity(name ??  string.Empty));
-     var name = await Name;
-     await _navigator.NavigateViewModelAsync<SecondModel>(this, data: new Entity(name!));
   }
 }
```

In this case we see:

- The agent correctly used the `Selection` operator to bind the `SelectedName` state to the `Names` list feed
- The agent did not attempt to use the `uen:Selection.Selected` attached property and instead left the `ListView` without a selected item binding. This is actually the correct approach as MVUX properly implements the [`ISelectionInfo` interface][iselectioninfo-msdocs]
- The proper signature of `ListFeed.Async` was used with a single parameter of type `AsyncFunc<...>`

If you watch the video closely, you will see explicit tool calls to `uno_platform_docs_search` with queries related to MVUX selection. This shows that the agent is properly utilizing the skill to guide its use of the Uno MCP tools.

## Conclusion

Agent Skills are a powerful way to guide your agents towards the right tools and information for the task at hand. No matter what tech stack you are currently using, creating a robust collection of Agent Skills can greatly enhance the agentic development experience.

In this day and age of rapidly evolving AI-assisted development, tooling is King. I would love to see how others have been utilizing the Uno MCP and App MCP tools in conjunction with Agent Skills. If you have any cool examples or use cases, please share them with me! Feel free to reach out via our [Discord server][uno-discord]!

Catch you in the next one :wave:

[jerome-social]: https://github.com/jeromelaban
[matthew-agent-blog]: https://platform.uno/blog/an-easy-agentic-workflow-for-developing-with-uno-platform-mcps/
[uno-mcp-blog]: https://platform.uno/blog/uno-mcp-vs-app-mcp/
[uno-docs]: https://platform.uno/docs/articles/intro.html
[mvux-selection]: https://platform.uno/docs/articles/external/uno.extensions/doc/Learn/Mvux/Advanced/Selection.html
[uno-skills-blog]: https://platform.uno/blog/contextual-ai-mcptools-vs-skills/
[iselectioninfo-msdocs]: https://learn.microsoft.com/en-us/windows/windows-app-sdk/api/winrt/microsoft.ui.xaml.data.iselectioninfo?view=windows-app-sdk-1.8
[uno-discord]: https://platform.uno/discord
[initial-skill-md]: https://github.com/kazo0/mvux-selection-skill/blob/4e6b805c4d4842a94af61745e6477eb38c5d5050/initial-mvux-selection.md
[refactored-skill-md]: https://github.com/kazo0/mvux-selection-skill/blob/4e6b805c4d4842a94af61745e6477eb38c5d5050/improved-mvux-selection.md
[mvux-selection-skill-gh]: https://github.com/kazo0/mvux-selection-skill