require 'spec_helper'

feature 'Rules' do
  describe 'List view' do
    before do
      create_list(:rule, 50, name: 'A Rule')
      visit '/exception_canary/rules'
    end

    it 'lists rules in a table' do
      expect(page).to have_content('A Rule')
    end

    it 'links to rule' do
      first(:link, 'A Rule').click
      expect(page).to have_content('Rule: A Rule')
    end

    it 'paginates' do
      expect(page).not_to have_content('Prev')
      click_on 'Next'
      expect(page).to have_content('Prev')
      expect(page).not_to have_content('Next')
    end
  end

  describe 'Show view' do
    let(:rule) { create :rule, name: 'A Rule', value: 'An Error Occurred' }

    before do
      create_list(:stored_exception, 100, title: rule.value, rule: rule)
      visit "/exception_canary/rules/#{rule.id}"
    end

    it 'shows rule' do
      expect(page).to have_content("Rule: #{rule.name}")
    end

    it 'lists exceptions in a table' do
      expect(page).to have_content('An Error Occurred')
    end

    it 'links to exception' do
      first(:link, rule.stored_exceptions.last.created_at.strftime('%Y-%m-%d %H:%M:%S')).click
      expect(page).to have_content("Stored Exception: #{rule.stored_exceptions.last.title}")
    end

    it 'does not link to rule' do
      within 'table:last' do
        expect(page).not_to have_content("Rule: #{rule.name}")
      end
    end

    it 'paginates stored exceptions' do
      expect(page).not_to have_content('Prev')
      click_on 'Next'
      expect(page).to have_content('Prev')
      expect(page).not_to have_content('Next')
    end
  end

  describe 'Creates rule' do
    let!(:matching_old_rule) { create :rule, name: 'An Old Rule', value: 'An Error Occurred', is_auto_generated: true }
    let!(:matching_stored_exception) { create :stored_exception, title: matching_old_rule.value, rule: matching_old_rule }
    let!(:nonmatching_old_rule) { create :rule, name: 'A Rule', value: 'A Misc Error Occurred' }
    let!(:nonmatching_stored_exception) { create :stored_exception, title: nonmatching_old_rule.value, rule: nonmatching_old_rule }

    before { visit '/exception_canary/rules/new' }

    context 'invalid fields' do
      it 'shows errors' do
        click_on 'Create Rule'
        expect(page).to have_content('Name can\'t be blank')
        expect(page).to have_content('Value can\'t be blank')
      end
    end

    context 'valid fields' do
      before do
        fill_in 'Name', with: 'The New Rule'
        fill_in 'Value', with: 'An Error Occurred'
        click_on 'Create Rule'
      end

      it 'creates rule and reclassifies exceptions' do
        expect(page).to have_content('Created rule and reclassified 1 exception.')
        within 'table:last' do
          expect(page).to have_content('An Error Occurred')
          expect(page).not_to have_content('A Misc Error Occurred')
        end
      end

      it 'destroys old auto generated rule' do
        click_on 'Rules'
        expect(page).not_to have_content('An Old Rule')
      end
    end
  end

  describe 'Updates rule' do
    let!(:rule) { create :rule, name: 'A Rule', value: 'An Error Occurred' }
    let!(:stored_exception) { create :stored_exception, title: rule.value, rule: rule }
    let!(:nonmatching_stored_exception) { create :stored_exception, title: 'A Misc Error Occurred' }

    before { visit "/exception_canary/rules/#{rule.id}/edit" }

    context 'invalid fields' do
      it 'shows errors' do
        fill_in 'Name', with: ''
        fill_in 'Value', with: ''
        click_on 'Update Rule'
        expect(page).to have_content('Name can\'t be blank')
        expect(page).to have_content('Value can\'t be blank')
      end
    end

    context 'valid fields' do
      before do
        fill_in 'Name', with: 'The New Rule'
        fill_in 'Value', with: 'A Misc Error Occurred'
        click_on 'Update Rule'
      end

      it 'updates rule and reclassifies exceptions' do
        expect(page).to have_content('Updated rule and reclassified 2 exceptions.')
        expect(page).to have_content('The New Rule')
        within 'table:last' do
          expect(page).not_to have_content('An Error Occurred')
          expect(page).to have_content('A Misc Error Occurred')
        end
      end

      it 'changes rule to no longer be auto generated' do
        click_on 'Rules'
        click_on 'New Rule'
        fill_in 'Name', with: 'The New Overriding Rule'
        fill_in 'Value', with: 'A Misc Error Occurred'
        click_on 'Create Rule'
        click_on 'Rules'
        expect(page).to have_content('The New Rule')
      end
    end

    context 'with buttons on rule page' do
      before { visit "/exception_canary/rules/#{rule.id}" }

      it 'updates action' do
        click_on 'Switch to Notify'
        expect(page).to have_content('Updated rule and reclassified 0 exceptions.')
        expect(page).to have_content('Switch to Suppress')
        expect(page).not_to have_content('Switch to Notify')
      end
    end

    context 'with buttons on exception page' do
      before { visit "/exception_canary/stored_exceptions/#{stored_exception.id}" }

      it 'updates action' do
        click_on 'Switch to Notify'
        expect(page).to have_content('Updated rule and reclassified 0 exceptions.')
        expect(page).to have_content('Switch to Suppress')
        expect(page).not_to have_content('Switch to Notify')
      end
    end
  end

  describe 'Deletes rule' do
    let!(:rule) { create :rule, name: 'An Outdated Rule' }
    let!(:stored_exception) { create :stored_exception, title: rule.value, rule: rule }

    before { visit "/exception_canary/rules/#{rule.id}" }

    it 'deletes rule and reclassifies exceptions' do
      click_on 'Delete'
      expect(page).to have_content('Deleted rule.')
      expect(page).not_to have_content('An Outdated Rule')
      click_on 'Exceptions'
      click_on stored_exception.created_at.strftime('%Y-%m-%d %H:%M:%S')
      expect(page).not_to have_content('An Outdated Rule')
    end
  end
end
