// Story.swift

import Foundation

protocol Story {
    var title: String { get }
    var text: String { get }

    func generateQuestion(for paragraph: String) async -> String
    func provideFeedback(for answer: String) async -> String
}

// CinderellaStory.swift

import Foundation

class CinderellaStory: Story {
    let title = "Cinderella"
    let text = """
        CINDERELLA, OR THE LITTLE GLASS SLIPPER

        Once there was a gentleman who married, for his second wife, the
        proudest and most haughty woman that was ever seen. She had, by a former
        husband, two daughters of her own humor, who were, indeed, exactly like
        her in all things. He had likewise, by another wife, a young daughter,
        but of unparalleled goodness and sweetness of temper, which she took
        from her mother, who was the best creature in the world.

        No sooner were the ceremonies of the wedding over but the mother-in-law
        began to show herself in her true colors. She could not bear the good
        qualities of this pretty girl, and the less because they made her own
        daughters appear the more odious. She employed her in the meanest work
        of the house: she scoured the dishes, tables, etc., and scrubbed madam’s
        chamber, and those of misses, her daughters; she lay up in a sorry
        garret, upon a wretched straw bed, while her sisters lay in fine rooms,
        with floors all inlaid, upon beds of the very newest fashion, and where
        they had looking-glasses so large that they might see themselves at
        their full length from head to foot.

        The poor girl bore all patiently, and dared not tell her father, who
        would have rattled her off; for his wife governed him entirely. When she
        had done her work, she used to go into the chimney-corner, and sit down
        among cinders and ashes, which made her commonly be called Cinderwench;
        but the youngest, who was not so rude and uncivil as the eldest, called
        her Cinderella. However, Cinderella, notwithstanding her mean apparel,
        was a hundred times handsomer than her sisters, though they were always
        dressed very richly.

        It happened that the King’s son gave a ball, and invited all persons of
        fashion to it. Our young misses were also invited, for they cut a very
        grand figure among the quality. They were mightily delighted at this
        invitation, and wonderfully busy in choosing out such gowns, petticoats,
        and head-clothes as might become them. This was a new trouble to
        Cinderella; for it was she who ironed her sisters’ linen, and plaited
        their ruffles; they talked all day long of nothing but how they should
        be dressed.

        “For my part,” said the eldest, “I will wear my red velvet suit with
        French trimming.”

        “And I,” said the youngest, “shall have my usual petticoat; but then,
        to make amends for that, I will put on my gold-flowered manteau, and my
        diamond stomacher, which is far from being the most ordinary one in the
        world.”

        They sent for the best tire-woman they could get to make up their
        head-dresses and adjust their double pinners, and they had their red
        brushes and patches from Mademoiselle de la Poche.

        Cinderella was likewise called up to them to be consulted in all these
        matters, for she had excellent notions, and advised them always for the
        best, nay, and offered her services to dress their heads, which they
        were very willing she should do. As she was doing this, they said to
        her:

        “Cinderella, would you not be glad to go to the ball?”

        “Alas!” said she, “you only jeer me; it is not for such as I am to go
        thither.”

        “Thou art in the right of it,” replied they; “it would make the people
        laugh to see a Cinderwench at a ball.”

        Anyone but Cinderella would have dressed their heads awry, but she was
        very good, and dressed them perfectly well They were almost two days
        without eating, so much were they transported with joy. They broke above
        a dozen laces in trying to be laced up close, that they might have a
        fine slender shape, and they were continually at their looking-glass.
        At last the happy day came; they went to Court, and Cinderella followed
        them with her eyes as long as she could, and when she had lost sight of
        them, she fell a-crying.

        Her godmother, who saw her all in tears, asked her what was the matter.

        “I wish I could--I wish I could--“; she was not able to speak the rest,
        being interrupted by her tears and sobbing.

        This godmother of hers, who was a fairy, said to her, “Thou wishest thou
        couldst go to the ball; is it not so?”

        “Y--es,” cried Cinderella, with a great sigh.

        “Well,” said her godmother, “be but a good girl, and I will contrive
        that thou shalt go.” Then she took her into her chamber, and said to
        her, “Run into the garden, and bring me a pumpkin.”

        Cinderella went immediately to gather the finest she could get, and
        brought it to her godmother, not being able to imagine how this pumpkin
        could make her go to the ball. Her godmother scooped out all the inside
        of it, having left nothing but the rind; which done, she struck it with
        her wand, and the pumpkin was instantly turned into a fine coach, gilded
        all over with gold.

        She then went to look into her mouse-trap, where she found six mice, all
        alive, and ordered Cinderella to lift up a little the trapdoor, when,
        giving each mouse, as it went out, a little tap with her wand, the mouse
        was that moment turned into a fine horse, which altogether made a very
        fine set of six horses of a beautiful mouse-colored dapple-gray. Being
        at a loss for a coachman,

        “I will go and see,” says Cinderella, “if there is never a rat in the
        rat-trap--we may make a coachman of him.”

        “Thou art in the right,” replied her godmother; “go and look.”

        Cinderella brought the trap to her, and in it there were three huge
        rats. The fairy made choice of one of the three which had the largest
        beard, and, having touched him with her wand, he was turned into a fat,
        jolly coachman, who had the smartest whiskers eyes ever beheld. After
        that, she said to Cinderella:

        “Go again into the garden, and you will find six lizards behind the
        watering-pot, bring them to me.”

        She had no sooner done so but her godmother turned them into six
        footmen, who skipped up immediately behind the coach, with their
        liveries all bedaubed with gold and silver, and clung as close behind
        each other as if they had done nothing else their whole lives. The Fairy
        then said to Cinderella:

        “Well, you see here an equipage fit to go to the ball with; are you not
        pleased with it?”

        “Oh! yes,” cried she; “but must I go thither as I am, in these nasty
        rags?”

        Her godmother only just touched her with her wand, and, at the same
        instant, her clothes were turned into cloth of gold and silver, all
        beset with jewels. This done, she gave her a pair of glass slippers, the
        prettiest in the whole world. Being thus decked out, she got up into her
        coach; but her godmother, above all things, commanded her not to stay
        till after midnight, telling her, at the same time, that if she stayed
        one moment longer, the coach would be a pumpkin again, her horses mice,
        her coachman a rat, her footmen lizards, and her clothes become just as
        they were before.

        She promised her godmother she would not fail of leaving the ball before
        midnight; and then away she drives, scarce able to contain herself for
        joy. The King’s son who was told that a great princess, whom nobody
        knew, was come, ran out to receive her; he gave her his hand as she
        alighted out of the coach, and led her into the ball, among all the
        company. There was immediately a profound silence, they left off
        dancing, and the violins ceased to play, so attentive was everyone to
        contemplate the singular beauties of the unknown new-comer. Nothing was
        then heard but a confused noise of:

        “Ha! how handsome she is! Ha! how handsome she is!”

        The King himself, old as he was, could not help watching her, and
        telling the Queen softly that it was a long time since he had seen so
        beautiful and lovely a creature.

        All the ladies were busied in considering her clothes and headdress,
        that they might have some made next day after the same pattern, provided
        they could meet with such fine material and as able hands to make them.

        The King’s son conducted her to the most honorable seat, and afterward
        took her out to dance with him; she danced so very gracefully that they
        all more and more admired her. A fine collation was served up, whereof
        the young prince ate not a morsel, so intently was he busied in gazing
        on her.

        She went and sat down by her sisters, showing them a thousand
        civilities, giving them part of the oranges and citrons which the Prince
        had presented her with, which very much surprised them, for they did not
        know her. While Cinderella was thus amusing her sisters, she heard the
        clock strike eleven and three-quarters, whereupon she immediately made a
        courtesy to the company and hasted away as fast as she could.

        When she got home she ran to seek out her godmother, and, after having
        thanked her, she said she could not but heartily wish she might go next
        day to the ball, because the King’s son had desired her.

        As she was eagerly telling her godmother whatever had passed at the
        ball, her two sisters knocked at the door, which Cinderella ran and
        opened.

        “How long you have stayed!” cried she, gaping, rubbing her eyes and
        stretching herself as if she had been just waked out of her sleep; she
        had not, however, any manner of inclination to sleep since they went
        from home.

        “If thou hadst been at the ball,” said one of her sisters, “thou wouldst
        not have been tired with it. There came thither the finest princess, the
        most beautiful ever was seen with mortal eyes; she showed us a thousand
        civilities, and gave us oranges and citrons.”

        Cinderella seemed very indifferent in the matter; indeed, she asked them
        the name of that princess; but they told her they did not know it, and
        that the King’s son was very uneasy on her account and would give all
        the world to know who she was. At this Cinderella, smiling, replied:

        “She must, then, be very beautiful indeed; how happy you have been!
        Could not I see her? Ah! dear Miss Charlotte, do lend me your yellow
        suit of clothes which you wear every day.”

        “Ay, to be sure!” cried Miss Charlotte; “lend my clothes to such a dirty
        Cinderwench as thou art! I should be a fool.”

        Cinderella, indeed, expected well such answer, and was very glad of the
        refusal; for she would have been sadly put to it if her sister had lent
        her what she asked for jestingly.

        The next day the two sisters were at the ball, and so was Cinderella,
        but dressed more magnificently than before. The King’s son was always by
        her, and never ceased his compliments and kind speeches to her; to whom
        all this was so far from being tiresome that she quite forgot what her
        godmother had recommended to her; so that she, at last, counted the
        clock striking twelve when she took it to be no more than eleven; she
        then rose up and fled, as nimble as a deer. The Prince followed, but
        could not overtake her. She left behind one of her glass slippers, which
        the Prince took up most carefully. She got home but quite out of breath,
        and in her nasty old clothes, having nothing left her of all her finery
        but one of the little slippers, fellow to that she dropped. The guards
        at the palace gate were asked:

        If they had seen a princess go out.

        Who said: They had seen nobody go out but a young girl, very meanly
        dressed, and who had more the air of a poor country wench than a
        gentlewoman.

        When the two sisters returned from the ball Cinderella asked them: If
        they had been well diverted, and if the fine lady had been there.

        They told her: Yes, but that she hurried away immediately when it struck
        twelve, and with so much haste that she dropped one of her little glass
        slippers, the prettiest in the world, which the King’s son had taken up;
        that he had done nothing but look at her all the time at the ball, and
        that most certainly he was very much in love with the beautiful person
        who owned the glass slipper.

        What they said was very true; for a few days after the King’s son caused
        it to be proclaimed, by sound of trumpet, that he would marry her whose
        foot the slipper would just fit. They whom he employed began to try it
        upon the princesses, then the duchesses and all the Court, but in vain;
        it was brought to the two sisters, who did all they possibly could
        to thrust their foot into the slipper, but they could not effect it.
        Cinderella, who saw all this, and knew her slipper, said to them,
        laughing:

        “Let me see if it will not fit me.”

        Her sisters burst out a-laughing, and began to banter her. The gentleman
        who was sent to try the slipper looked earnestly at Cinderella, and,
        finding her very handsome, said:

        It was but just that she should try, and that he had orders to let
        everyone make trial.

        He obliged Cinderella to sit down, and, putting the slipper to her foot,
        he found it went on very easily, and fitted her as if it had been made
        of wax. The astonishment her two sisters were in was excessively great,
        but still abundantly greater when Cinderella pulled out of her pocket
        the other slipper, and put it on her foot. Thereupon, in came her
        godmother, who, having touched with her wand Cinderella’s clothes, made
        them richer and more magnificent than any of those she had before.

        And now her two sisters found her to be that fine, beautiful lady whom
        they had seen at the ball. They threw themselves at her feet to beg
        pardon for all the ill-treatment they had made her undergo. Cinderella
        took them up, and, as she embraced them, cried:

        That she forgave them with all her heart, and desired them always to
        love her.

        She was conducted to the young prince, dressed as she was; he thought
        her more charming than ever, and, a few days after, married her.
        Cinderella, who was no less good than beautiful, gave her two sisters
        lodgings in the palace, and that very same day matched them with two
        great lords of the Court.
        """

    private let openAIManager: OpenAIManager

    init(openAIManager: OpenAIManager) {
        self.openAIManager = openAIManager
    }

    func generateQuestion(for paragraph: String) async -> String {
        let questionPrompt = "You are Socrates, an AI TUTOR helping a child understand and reflect on any fairy tale they are reading or listening to. The child has mentioned \"\(paragraph)\" in relation to the fairy tale. Your task is to create a prompt that encourages the child to reflect on the events and characters in the tale. Ask questions that help the child recall specific details from the story, understand the actions and motivations of the characters, and discuss the outcomes of their actions. Use simple, engaging language and make sure the questions are age-appropriate. Remember, your response should be in English and suitable for a 2-7 year old. ASK A SINGLE EASY QUESTION."
        return await openAIManager.sendTextToOpenAI(questionPrompt)
    }

    func provideFeedback(for answer: String) async -> String {
        let feedbackPrompt = "You are Socrates, an AI TUTOR helping a child understand and reflect on any fairy tale they are reading or listening to. The child has given the following answer to a question about the fairy tale: \"\(answer)\". Your task is to provide positive and constructive feedback that encourages the child to think more deeply about the story. Use simple, engaging language and make sure the feedback is age-appropriate. Remember, your response should be in English and suitable for a 2-7 year old."
        return await openAIManager.sendTextToOpenAI(feedbackPrompt)
    }
}
