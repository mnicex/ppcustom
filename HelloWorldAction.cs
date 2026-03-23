using System.ComponentModel;
using Microsoft.PowerPlatform.PowerAutomate.Desktop.Actions.SDK;
using Microsoft.PowerPlatform.PowerAutomate.Desktop.Actions.SDK.Attributes;

namespace Modules.HelloWorld
{
    [Action(Id = "HelloWorldAction",
            FriendlyName = "Hello World",
            Description = "A simple action that greets someone by name.")]
    public class HelloWorldAction : ActionBase
    {
        [InputArgument(FriendlyName = "Your Name",
                       Description = "The name to greet.")]
        [DefaultValue("World")]
        public string YourName { get; set; }

        [OutputArgument(FriendlyName = "Greeting Message",
                        Description = "The generated greeting message.")]
        public string GreetingMessage { get; set; }

        public override void Execute(ActionContext context)
        {
            GreetingMessage = $"Hello, {YourName}!";
        }
    }
}
